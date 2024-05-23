module V2
  class SendToMsGraphService
    attr_accessor :site_id, :list_id, :drive_id, :root_graph_url

    def initialize(action)
      @root_graph_url = action['graph_url']
      @site_id = action['site_id']
      @list_id = action['list_id']
      @drive_id = action['drive_id']
    end

    def post_to_ms_list(submission, id)
      uri = URI.parse("#{root_graph_url}/sites/#{site_id}/lists/#{list_id}/items")

      @connection ||= Faraday.new(uri) do |conn|
      end

      payload = ms_list_payload(submission, id)
      Rails.logger.info('=============')
      Rails.logger.info('sending this payload:')
      Rails.logger.info(payload)

      response = @connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{get_auth_token}"
        req.body = payload
      end

      parsed_response = JSON.parse(response.body)
      Rails.logger.info('=============')
      Rails.logger.info(response)
      Rails.logger.info(response.status)
      Rails.logger.info('=============')
      Rails.logger.info(parsed_response)
      Rails.logger.info('=============')

      parsed_response
    end

    def send_attachment_to_drive(attachment)
      uri = URI.parse("#{root_graph_url}/sites/#{site_id}/drive/items/#{drive_id}:/#{attachment.filename}:/content")

      @connection ||= Faraday.new(uri) do |conn|
      end

      response = @connection.post do |req|
        req.headers['Content-Type'] = 'text/plain'
        req.headers['Authorization'] = "Bearer #{get_auth_token}"
        req.body = attachment
      end

      parsed_response = JSON.parse(response.body)
      Rails.logger.info(parsed_response)

      parsed_response
    end

    def get_auth_token
      response = auth_connection.post do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(form_data)
      end

      response_body = JSON.parse(response.body)

      response_body['access_token']
    end

    def ms_list_payload(submission, id)
      # submission.to_json

      new_data = {
        'fields' => {
          'Title' => id
        }
      }

      merge_data = []

      submission['pages'].each do |page|
        page['answers'].each do |answer|
          keystring = answer['field_id'].to_s
          md5name = Digest::MD5.hexdigest keystring
          md5stripped = md5name.tr('0-9', '')
          merge_data << { md5stripped => answer['answer'] }
        end
      end

      result_hash = {}

      merge_data.each do |hash|
        result_hash.merge!(hash)
      end

      new_data['fields'].merge!(result_hash).to_json
    end

    private

    def auth_connection
      @auth_connection ||= Faraday.new(URI.parse(auth_url)) do |conn|
        conn.response :raise_error
        conn.request :multipart
        conn.request :url_encoded
        conn.adapter :net_http
      end
    end

    def form_data
      {
        client_id: admin_app,
        client_secret: admin_secret,
        grant_type: 'client_credentials',
        resource: 'https://graph.microsoft.com/'
      }
    end

    def admin_app
      ENV['MS_ADMIN_APP_ID']
    end

    def admin_secret
      ENV['MS_ADMIN_APP_SECRET']
    end

    def auth_url
      ENV['MS_OAUTH_URL']
    end
  end
end
