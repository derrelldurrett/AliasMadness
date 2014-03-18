class User < ActiveRecord::Base
  include HashHelper
  attr_accessible :name, :password, :password_confirmation, :email, :role#, as: :admin
  attr_accessor :remember_for_email
  has_one :bracket#, inverse_of: :users
  before_validation :do_validation_setup
  before_save :create_remember_token
  before_save :create_initial_bracket
  after_save :attach_user_to_bracket
  has_secure_password
  validates(:name, presence: true, length: { maximum: 50, minimum: 3 })
  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute,
      (options[:message] || value+" is not an email") unless
      value =~
      Regexp.new(%q(\A([^@\s]+)@((?:[-.a-z0-9]+)\.[a-z]{2,})\z), Regexp::IGNORECASE)
    end
  end
  validates :email, presence: true,
  email: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  simple_roles do
    strategy :one
    valid_roles :player, :admin
  end

  HashHelper.hash_vars= %i(name email)

  private

  def create_initial_bracket
    self.bracket = BracketFactory.instance.create_bracket
  end

  def attach_user_to_bracket
    self.bracket.user= self
    self.bracket.save!
  end

  def do_validation_setup
    self.email.downcase!
    unless admin?
      self.password =
          self.password_confirmation =
              self.remember_for_email =
                  SecureRandom.base64(24) #create a  32-character-length password
    end
  end


  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

end
