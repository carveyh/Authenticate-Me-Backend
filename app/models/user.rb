# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  #FIGVAPEBR

  has_secure_password

  validates :session_token, presence: true, uniqueness: true
  validates :username, 
    uniqueness: true,
    length: { in: 3..30, message: "%{attribute} must be between 3 and 30 characters long" },
    format: { without: URI::MailTo::EMAIL_REGEXP, message: "%{attribute} can't be an email" }
  validates :email, 
  uniqueness: true,
  length: { in: 3..255 }, 
  format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 6..255 }, allow_nil: true
  #Reminder: allow_nil: true will skip validation if the column is nil.

  before_validation :ensure_session_token

  def self.find_by_credentials(credential, password) #flexibly accepts username or email!
    # Is credential email or username?
    if(credential =~ /\A(\S+)@(.+)\.(\S+)\z/) #email regex pattern that prevents whitespace, allows multiple periods after `@`
      @user = self.find_by(email: credential)
    else
      @user = self.find_by(username: credential)
    end

    # If user found and pw authenticates, return @user, else nil
    if(@user && @user.authenticate(password))
      return @user
    else
      return nil
    end
  end

  def reset_session_token!
    # self.session_token = self.generate_unique_session_token
    # # self.update! #NEED TO REVISIT SYNTAX, THIS CURRENTLY THROWS ERROR
    # self.save!
    # self.session_token

    self.update!(session_token: self.generate_unique_session_token)
    self.session_token
  end

  private

  def generate_unique_session_token
    possible_token = SecureRandom::urlsafe_base64
    while User.find_by(session_token: possible_token)
      possible_token = SecureRandom::urlsafe_base64
    end
    possible_token
  end

  def ensure_session_token
    self.session_token ||= self.generate_unique_session_token
  end

end
