module TestdroidApi
  class Client
    class Project

      attr_reader :id, :name, :description, :app_file, :test_file
      def initialize(client, config)
        @client      = client
        @id          = config['id']
        @name        = config['name']
        @description = config['description']

        #TODO: Add uploadTimeslate
        @app_file    = config['appFile'] && config['appFile']['originalName']

        #TODO: Add uploadTime
        @test_file   = config['testFile'] && config['testFile']['originalName']
      end

      # Upload application binary
      # @param path path to application file
      def upload_app_file(path)
        endpoint = "projects/#{id}/apks/application"

        file     = File.new(path)
        digest   = mh5digest(file)
        params   = { :file => file, :multipart => true }

        res_name = "upload#{id}application#{digest}"
        extra_headers = {'X-Testdroid-MD5' => digest}

        @client.post_api_request(endpoint, params, res_name, extra_headers )
      end

      # Upload test binary
      # @param path path to test file
      def upload_test_file(path)
        endpoint = "projects/#{id}/apks/instrumentation"

        file     = File.new(path)
        digest   = mh5digest(file)
        params   = { :file => file, :multipart => true }

        res_name = "upload#{id}instrumentation#{digest}"
        extra_headers = {'X-Testdroid-MD5' => digest}

        @client.post_api_request(endpoint, params, res_name, extra_headers )
      end

      # Delete project
      def delete!
        res_name = "project/#{id}"
        endpoint = "projects/#{id}/delete"

        @client.post_api_request(endpoint, nil, res_name)
      end

      # Start new test run
      # @return [TestdroidApi::Client::Project::TestRun]
      #
      # @param device_group [TestdroidApi::Client::DeviceGroup] devices to be tested
      # @param instatest    [Boolean]                           run project in instatest mode
      # @param screenshots  [Boolean]                           take screenshots automatically
      def create_test_run(device_group = 'all devices', instatest = false, screenshots = false)
        res_name = "project/run/#{id}"
        endpoint = "projects/#{id}/run"
        params   = {
          :instatestMode   => instatest,
          :autoScreenshots => screenshots,
          :usedClusterId   => get_group_id(device_group)
        }
        test_run = @client.post_api_request(endpoint, params, res_name)

        TestdroidApi::Client::Project::TestRun.new(@client, self, test_run)
      end

      # Returns project runs from project
      # @return [Array<Project>]
      def test_runs
        res_name = "runs"
        endpoint = "projects/#{id}/runs"

        configs = @client.get_api_request(endpoint, res_name)

        configs.map{|config|
          TestdroidApi::Client::Project::TestRun.new(@client, self, config)
        }
      end

      def config
        raise NotImplementedError
      end

      def update_config(new_config)
        raise NotImplementedError
      end
      private
        def mh5digest(file)
          Digest::MD5.hexdigest(file.read)
        end

      def get_group_id(object)
        (object.respond_to? :id) ? object.id : object
      end

    end
  end
end
