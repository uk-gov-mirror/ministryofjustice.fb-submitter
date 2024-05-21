module V2
  class SendToMsGraphService
    attr_accessor :site_id, :list_id, :drive_id, :root_graph_url

    def initialize(root_graph_url: ENV['MS_GRAPH_ROOT_URL'], site_id: ENV['MS_SITE_ID'], list_id: ENV['MS_LIST_ID'], drive_id: ENV['MS_DRIVE_ID'])
      @root_graph_url = root_graph_url
      @site_id = site_id
      @list_id = list_id
      @drive_id = drive_id
    end

    def post_to_ms_list(submission)
      uri = URI.parse("#{root_graph_url}/sites/#{site_id}/lists/#{list_id}")

      @connection ||= Faraday.new(uri) do |conn|
      end

      response = @connection.post do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{get_auth_token}"
        req.body = ms_list_payload(submission)
      end

      JSON.parse(response.body)
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

      JSON.parse(response.body)
    end

    def get_auth_token
      response = auth_connection.post do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(form_data)
      end

      response_body = JSON.parse(response.body)

      response_body['access_token']
    end

    def ms_list_payload(submission)
      submission.to_json
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
