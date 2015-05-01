require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Coursera < OmniAuth::Strategies::OAuth2
      option :client_options, {
          site: 'https://accounts.coursera.org',
          authorize_url: 'https://accounts.coursera.org/oauth2/v1/auth',
          token_url: 'https://accounts.coursera.org/oauth2/v1/token'
      }

      def request_phase
        super
      end

      uid do
        raw_info['elements'].first['id'].to_s
      end

      info do
        {
          name: raw_info['elements'].first['name'].to_s,
          locale: raw_info['elements'].first['locale'].to_s,
          timezone: raw_info['elements'].first['timezone'].to_s,
          privacy: raw_info['elements'].first['privacy'].to_i
          enrollments: raw_enrollments_info['enrollments'],
          courses: raw_enrollments_info['courses']
        }
      end

      extra do
        {
          raw_info: raw_info,
          raw_enrollments_info: raw_enrollments_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('https://api.coursera.org/api/externalBasicProfiles.v1?q=me&fields=name,timezone,locale,privacy').parsed
      end
      
      def raw_enrollments_info
        access_token.options[:mode] = :query
        @raw_enrollments_info ||= access_token.get('https://api.coursera.org/api/users/v1/me/enrollments').parsed
      end
    end
  end
end
