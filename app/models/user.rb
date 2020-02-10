# frozen_string_literal: true

class User < ApplicationRecord
  require 'helpers/hash_helper'
  require 'helpers/hash_class_helper'
  extend HashClassHelper
  attr_accessor :remember_for_email
  has_one :bracket, inverse_of: :user
  before_validation :do_validation_setup
  before_save :create_remember_token
  before_save :create_initial_bracket
  after_save :attach_user_to_bracket
  has_secure_password
  validates :name, presence: true, length: { maximum: 50, minimum: 1 }
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      # puts %q(Checking user )+record.name+%Q( [id: #{record.id}])+%q( with email )+value
      unless value&.match?(Regexp.new(%q(\A([^@\s]+)@((?:[-.a-z0-9]+)\.[a-z]{2,})\z), Regexp::IGNORECASE))
        record.errors.add attribute,
                          (options[:message] || value + %q( is not an email))
      end
    end
  end
  validates :email, presence: true, email: true,
                    uniqueness: { case_sensitive: false,
                                  message: '%{value} is already taken.' }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  ROLES = %w[admin player].freeze

  self.hash_vars = %i(name email)

  def to_s
    s = name
    s += " (#{@current_score})" unless @current_score.nil?
    s
  end

  # TODO: move this into a module that the downloader can modify to taste.
  def score(reference_bracket)
    score = current_score || 0
    # if score==0 or self.updated_at < reference_bracket.newest_game_date
    score = @current_score = compute_score(reference_bracket)
    #puts(%Q(Updating #{name}'s score to #{score}))
    update_attributes!(current_score: score)
    # end
    score
  end

  def compute_score(reference_bracket)
    my_score = 0
    reference_bracket.games_by_label.zip(bracket.games_by_label) do |g_arr|
      next if g_arr.any? {|g|g&.winner.nil?}
      my_score += (g_arr[0]&.winner&.seed * g_arr[0].round_multiplier) if g_arr[0]&.winner == g_arr[1]&.winner
    end
    my_score
  end

  def admin?
    role == :admin.to_s
  end

  private

  def resource_params
    params.require(:user).permit(%i[name password password_confirmation email role current_score bracket_locked?])
  end

  def create_initial_bracket
    self.bracket = BracketFactory.instance.create_bracket if self.bracket.nil?
  end

  def attach_user_to_bracket
    b = bracket
    if bracket.user.nil?
      bracket.user = self
      bracket.save!
      # puts "saving bracket for user #{name} with #{bracket.games.length} games.  Id: #{bracket.id}"
    end
  end

  def do_validation_setup
    email.downcase!
    unless admin?
      self.password =
          self.password_confirmation =
              remember_for_email =
                  SecureRandom.base64(24) #create a  32-character-length password
    end
  end

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
