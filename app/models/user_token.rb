require 'active_record'
require 'parsed_cookie_token'
require 'time'
require 'user'

# A token, attached to a User, used to “remember” that user.
# Typically used to keep users logged-in via cookies.
class UserToken < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :token, presence: true
  validate :validate_expires_in_future, on: :create

  scope :expired, -> { where('expires_at <= ?', Time.zone.now) }
  default_scope -> { where('(expires_at IS NULL OR expires_at > ?)', Time.zone.now) }

  def validate_expires_in_future
    expiry = expires_at
    errors.add(:expires_at, 'must be in the future') unless expiry.blank? || (expiry > Time.zone.now)
  end

  # Parse a cookie_token to find a matching, non-expired, UserToken.
  def self.from_cookie_token(cookie_token)
    token_parsed = Wayground::ParsedCookieToken.new(cookie_token)
    where(user_id: token_parsed.id, token: token_parsed.token).includes(:user).first!
  rescue Wayground::ParsedCookieToken::InvalidToken, ActiveRecord::RecordNotFound
    # return a 'null' user token
    new(token: '')
  end

  def self.cleanup_expired_tokens
    unscoped.expired.delete_all
  end
end
