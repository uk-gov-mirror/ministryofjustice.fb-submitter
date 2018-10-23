module Adapters
  class ServiceUrlResolver
    attr_accessor :service_slug, :environment_slug

    def initialize(params={})
      @service_slug = params[:service_slug]
      @environment_slug = params[:environment_slug] || ENV['FB_ENVIRONMENT_SLUG']
    end

    def ensure_absolute_urls(urls=[])
      urls.map{|u| ensure_absolute_url(u)}
    end

    def ensure_absolute_url(url)
      uri = URI.parse(url)
      unless uri.absolute?
        uri = resolve_uri_to_service( uri )
      end
      uri.to_s
    end

    def resolve_uri_to_service(uri)
      env = Rails.configuration.x.service_environments[environment_slug.to_sym]

      uri.host = internal_host(service_slug, environment_slug)
      uri.scheme = env[:protocol].split(':').first
      uri.port = env[:internal_service_port]
      uri
    end

    def internal_tld(service_slug, environment_slug)
      ['formbuilder', 'services', environment_slug].join('-')
    end

    def internal_host(service_slug, environment_slug)
      [
        service_slug,
        internal_tld(service_slug, environment_slug)
      ].join('.')
    end
  end
end
