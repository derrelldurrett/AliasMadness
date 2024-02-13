# frozen_string_literal: true

class User < ApplicationRecord
  extend Helpers::HashClassHelper
  attr_accessor :remember_for_email
  has_one :bracket
  has_many :heckles_user
  has_many :heckles, through: :heckles_user
  scope :players, -> {where role: :player}
  before_validation :do_validation_setup
  before_save :create_remember_token
  before_save :create_initial_bracket
  after_save :attach_user_to_bracket
  after_create_commit :create_chat_name
  has_secure_password
  validates :name, presence: true, length: { maximum: 50, minimum: 1 }
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
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
# self.json_client_ids = %i[id chat_name]

  def to_s
    s = name
    s += " (#{@current_score})" unless @current_score.nil?
    s
  end

  def private_channel
    PrivateChannel.broadcasting_for(self)
  end

  # TODO: move this into a module that the downloader can modify to taste.
  def score(reference_bracket)
    score = current_score || 0
    # if score==0 or self.updated_at < reference_bracket.newest_game_date
    score = @current_score = compute_score(reference_bracket)
    #puts(%Q(Updating #{name}'s score to #{score}))
    update!(current_score: score)
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

  # Kinda weird we'd need this to be public, but you shouldn't call it.
  def identify_unique_chat_name(existing_names, min_tokens)
    n_tokens = min_tokens
    tokens = name.split(/\s+/)
    try_name = tokens[0,n_tokens] * ' '
    fix_ids = []
    while existing_names.key? try_name and existing_names[try_name][:id] != id do
      fix_ids << existing_names[try_name]
      try_name = tokens[0,n_tokens] * ' '
      n_tokens += 1
    end
    update!(chat_name: try_name)
    existing_names[try_name] = {id: id, name: name}
    fix_ids.each do |fix_id_h|
      User.find(fix_id_h[:id]).identify_unique_chat_name(existing_names, min_tokens+1)
    end
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
              self.remember_for_email =
                  SecureRandom.base64(24) #create a  32-character-length password
    end
  end

  def create_remember_token
    self.remember_token ||= SecureRandom.urlsafe_base64
  end

  # Do this so that it's unique, and modify other names as necessary to get it unique using whole tokens, which must
  # be at least two characters long.
  def create_chat_name
    existing_names_with_id = User.select('id, name, chat_name').each_with_object({}) do |u, e|
      next if self == u
      u.chat_name ||= u.name.split(/\s+/).first
      e[u.chat_name]= { id: u.id, name: u.name }
    end
    identify_unique_chat_name(existing_names_with_id, 1)
  end
end
