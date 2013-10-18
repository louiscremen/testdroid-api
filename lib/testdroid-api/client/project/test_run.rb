module TestdroidApi
  class Client
    class Project
      class TestRun

        attr_reader :project_id, :id, :name, :state
        def initialize(client, project, config)
          @client     = client
          @project_id = project.id

          update(config)
        end

        # Updates test_run information
        def update!
          res_name = "run"
          endpoint = "projects/#{@project_id}/runs/#{id}"

          config   = @client.get_api_request(endpoint, res_name)

          update(config)
        end

        def results
          raise NotImplementedError
        end

        # Returns devices that the run was executed on.
        # @return [Array<TestdroidApi::Client::TestRun::DeviceRun>]
        def device_runs
          res_name = "deviceRuns"
          endpoint = "projects/#{@project_id}/runs/#{id}/device-runs"

          results  = @client.get_api_request(endpoint, res_name)
          results.map{|device_run|
            TestdroidApi::Client::Project::TestRun::DeviceRun.new(@client, self, device_run)
          }
        end

        # Get test run's screenshots as a zip file.
        def screenshots_zip
          res_name = 'screenshots.zip'
          endpoint = "projects/#{@project_id}/runs/#{id}/screenshots.zip"

          @client.get_file(endpoint, res_name)
        end

        # Get test run's junit results as a zip file
        def junit_results_zip
          res_name = 'junits.zip'
          endpoint = "projects/#{@project_id}/runs/#{id}/junits.zip"

          @client.get_file(endpoint, res_name)
        end

        # Get test run's logs as a zip file.
        def logs_zip
          res_name = 'logs.zip'
          endpoint = "projects/#{@project_id}/runs/#{id}/logs.zip"

          @client.get_file(endpoint, res_name)
        end

        # Did test run finish
        # @return [Boolean]
        def finished?
          state == 'FINISHED'
        end

        private
          def update(config)
            @id    = config['id']
            @name  = config['displayName']
            @state = config['groupState']
          end
      end
    end
  end
end
