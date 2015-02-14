require 'helpers/hash_helper'
require 'helpers/hash_class_helper'
require 'assets/errors/bad_programmer_error'
require 'bracket'
class User < ActiveRecord::Base
  include HashHelper
  extend HashClassHelper
  attr_accessible :name, :password, :password_confirmation, :email, :role, :bracket_locked?
  attr_accessor :remember_for_email
  has_one :bracket
  delegate :current_score, to: :bracket
  before_validation :do_validation_setup
  before_save :create_remember_token
  before_save :create_initial_bracket
  after_save :attach_user_to_bracket
  has_secure_password
  validates :name, presence: true, length: {maximum: 50, minimum: 3}
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      # puts %q(Checking user )+record.name+%Q( [id: #{record.id}])+%q( with email )+value
      record.errors.add attribute,
                        (options[:message] || value+%q( is not an email)) unless value =~
          Regexp.new(%q(\A([^@\s]+)@((?:[-.a-z0-9]+)\.[a-z]{2,})\z), Regexp::IGNORECASE)
    end
  end
  validates :email, presence: true, email: true,
            uniqueness: {case_sensitive: false, message: %Q(%{value} is already taken.)}
  validates :password, presence: true, length: {minimum: 6}
  validates :password_confirmation, presence: true

  simple_roles do
    strategy :one
    valid_roles :player, :admin
  end

  self.hash_vars= %i(name email)

  def self.find_by_remember_token(token)
    User.where(remember_token: token).first
  end

  def self.ordered_by_current_score
    # reverse to get descending order.
    (User.where(role: :player).sort_by { |p| p.current_score }).reverse
  end

  def current_score
    bracket.current_score
  end

  private

  def create_initial_bracket
    # puts 'creating initial bracket'
    # puts caller
    self.bracket = BracketFactory.instance.create_bracket if self.bracket.nil?
  end

  def attach_user_to_bracket
    if self.bracket.user.nil?
      self.bracket.user= self
      self.bracket.save!
      # puts "saving bracket for user #{self.name} with #{self.bracket.games.length} games.  Id: #{self.bracket.id}"
    end
  end

  def do_validation_setup
    self.email=self.email.downcase
  end

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
