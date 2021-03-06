require_relative 'base'
require 'authentication'
require 'user'

module Wayground
  module Login

    # attempt to authenticate with an Authentication assigned to a different user
    class WrongUserForAuthentication < RuntimeError; end

    # Handle logging in from OAuth authentication.
    # Requires the user_class to have an authentications association.
    class OauthLogin < Base
      attr_accessor :current_user, :auth
      attr_reader :authentication

      protected

      def post_initialize(current_user: nil, auth: nil)
        self.current_user = current_user
        self.auth = auth
      end

      # possible conditions:
      # - signed in user via existing authentication
      # - added new authentication to existing user
      # - created new user and authentication
      # - wrong user tried to use existing authentication
      def find_user
        begin
          authentication = Authentication.where(provider: provider, uid: auth['uid']).first!
        rescue ActiveRecord::RecordNotFound
          authentication = create_authentication!
        end
        @authentication = authentication
        authentication.user
      end

      private

      def create_authentication!
        unless current_user
          user = user_class.new(name: auth_name, email: user_info['email'])
          self.current_user = user
        end
        authentication = current_user.authentications.build(authentication_attrs)
        current_user.save!
        authentication
      end

      # try to get a name from the auth (prefer 'name' over 'nickname')
      def auth_name
        user_info['name'] || user_info['nickname']
      end

      # convert the data in the auth user info into a hash of authentication attributes
      def authentication_attrs
        auth_params = user_info
        {
          provider: provider, uid: auth['uid'],
          nickname: auth_params['nickname'], name: auth_params['name'],
          email: auth_params['email'], location: auth_params['location'],
          image_url: auth_params['image'], description: auth_params['description'],
          url: url_from_provider
        }
      end

      # figure out the user’s url on the service, if available
      def url_from_provider
        case provider
        when 'facebook'
          urls = auth['urls']
          urls['Facebook'] if urls.present?
        when 'twitter'
          "https://twitter.com/#{user_info['nickname']}"
        end
      end

      def user_info
        unless @user_info
          @user_info =
            if provider == 'twitter'
              auth['info'] || {}
            else
              auth['user_info'] || {}
            end
        end
        @user_info
      end

      def provider
        @provider ||= auth['provider']
      end
    end

  end
end
