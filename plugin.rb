require 'openssl'
require 'base64'

enabled_site_setting :postal_webhook_public_key
enabled_site_setting :discourse_base_url
enabled_site_setting :discourse_api_key
enabled_site_setting :discourse_api_username

after_initialize do
  module ::DiscoursePostal
    class Engine < ::Rails::Engine
      engine_name "discourse-postal"
      isolate_namespace DiscoursePostal

      class << self
        # signature verification filter
        def verify_signature(key, signature, body)
          rsa_key = OpenSSL::PKey::RSA.new("-----BEGIN PUBLIC KEY-----\n" + key + "\n-----END PUBLIC KEY-----")
          rsa_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), body)
        end

        # posting the email through the discourse api
        def post(url, params)
          Excon.post(url,
            :body => URI.encode_www_form(params),
            :headers => { "Content-Type" => "application/x-www-form-urlencoded" })
        end
      end
    end
  end

  require_dependency "application_controller"

  class DiscoursePostal::PostalController < ::ApplicationController
    before_action :verify_signature

    def incoming
      # available fields:
      # https://github.com/postalhq/postal/blob/0f30a53ebbc0f12eddd61f1397b955276bcd214f/lib/postal/http_sender.rb#L66-L95
      p_body    = params['plain_body']
      p_subj    = params['subject']
      p_to      = params['to']
      p_from    = params['from']
      p_date    = params['date']

      m = Mail::Message.new do
        to      p_to
        from    p_from
        date    p_date
        subject p_subj
        body    p_body
      end

      handler_url = SiteSetting.discourse_base_url + "/admin/email/handle_mail"

      params = {'email'        => m.to_s,
                'api_key'      => SiteSetting.discourse_api_key,
                'api_username' => SiteSetting.discourse_api_username}
      ::DiscoursePostal::Engine.post(handler_url, params)

      render plain: "done"
    end

    # we mark this controller as an API
    # in order to skip CSRF and other discourse filters
    def is_api?
      true
    end

    private

    def verify_signature
      key = SiteSetting.postal_webhook_public_key
      signature = request.headers['HTTP_X_POSTAL_SIGNATURE']
      body = request.body.read
      unless ::DiscoursePostal::Engine.verify_signature(key, signature, body)
        render json: {}, :status => :unauthorized
      end
    end
  end


  DiscoursePostal::Engine.routes.draw do
    post "/incoming" => "postal#incoming"
  end

  Discourse::Application.routes.append do
    mount ::DiscoursePostal::Engine, at: "postal"
  end
end
