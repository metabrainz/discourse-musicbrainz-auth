require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Musicbrainz < ::OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, :musicbrainz

      option :scope, "profile email"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site          => 'https://musicbrainz.org',
        :authorize_url => '/oauth2/authorize',
        :token_url     => '/oauth2/token'
      }

      option :provider_ignores_state, true

      option :user_info_url, '/oauth2/userinfo'

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid{ raw_info['sub'] }

      info do
        {
          :nickname => raw_info['sub'],
          :name => raw_info['sub'],
          :email => raw_info['email'],
          :email_verified => raw_info['email_verified'],
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        opts = {
          :headers => {
            'Authorization' => "Bearer #{access_token.token}"
          }
        }
        @raw_info ||= access_token.get(options.user_info_url, opts).parsed
      end

      def callback_url
        # Workaround for https://github.com/omniauth/omniauth-oauth2/issues/93
        full_host + script_name + callback_path
      end
    end
  end
end
