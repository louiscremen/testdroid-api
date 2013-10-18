module TestdroidApi
  class Client
    USERS_URL = "https://users.testdroid.com/api/v1/authorize"
    CLOUD_URL = "https://cloud.testdroid.com"

    # Initialize a Client object with TestDroid credentials
    #
    # @param username [String] Username
    # @param password [String] Password
    def initialize(username, password)
      @username = username
      @password = password
      @api_key  = ""
    end

    # Authenticate client and retrieve apiKey
    # @return [String] token
    def authenticate!
      response = post(USERS_URL, { "email" => @username, "password" => @password})
      raise 'Could not authenticate, are you sure you have the right credentials?' if !response['secretApiKey']

      @api_key = response['secretApiKey']
    end

    # List all projects
    # @param name [String] project name to match
    # @return [Array<TestdroidApi::Client::Project>]
    def projects(name = nil)
      configs = get_api_request('projects')

      name ? find_projects_by(name, configs) : create_projects_from(configs)
    end

    # Create new project
    # @param name [String] name of the project
    # @param description [String] project's description
    # @return [TestdroidApi::Client::Project]
    def create_project(name, description)
      config  = post_api_request('projects', { :name => name, :description => description })

      Project.new(self, config)
    end

    # Get user’s clusters
    # @param name [String] if given only matching device clusters will be returned
    # @return [Array<TestdroidApi::Client::DeviceGroup>]
    def device_groups(name = nil)
      devices = get_api_request('clusters')

      name ? find_device_groups_by(name, devices) : create_device_groups_from(devices)
    end

    # @api private
    def post_api_request(endpoint, params = nil, resource_name = endpoint, extra_headers = {})
      check_api_key
      post(get_endpoint(endpoint), params, get_auth_header(resource_name).merge(extra_headers))
    end

    # @api private
    def get_api_request(endpoint, resource_name = endpoint)
      check_api_key
      get(get_endpoint(endpoint), get_auth_header(resource_name) )
    end

    # @api private
    def get_file(endpoint, resource_name = endpoint)
      check_api_key
      RestClient.get(get_endpoint(endpoint), get_auth_header(resource_name))
    end


    private
      def post(url, params, headers = nil)
          JSON.parse(RestClient.post(url, params, headers))
        end

      def get(url, params=nil)
        JSON.parse(RestClient.get(url, params))
      end

      def get_auth_header(resourceName)
          nonce = get_nonce
          digestdata = @api_key + ":" + nonce + ":" + resourceName
          digest = Digest::SHA256.hexdigest(digestdata)
          {'X-Testdroid-Authentication' => @username + " " + nonce + " " + digest}
      end

      def get_nonce
          chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
          nonce = ''
          6.times do nonce << chars[rand(chars.size)] end
          nonce
      end

      def create_projects_from(configs)
        configs.map{|project_config|
          Project.new(self, project_config)
        }
      end

      def find_projects_by(name, configs)
        create_projects_from(configs).delete_if{|project|
          project.name != name
        }
      end

      def find_device_groups_by(name, devices)
        create_device_groups_from(devices).delete_if{|group|
          group.display_name != name
        }
      end

      def create_device_groups_from(devices)
        devices.map{|group|
          DeviceGroup.new(self, group)
        }
      end

      def check_api_key
        raise("Are you sure you've authenticated?") if @api_key.empty?
      end

      def get_endpoint(name)
        "#{CLOUD_URL}/api/v1/#{name}"
      end
  end
end