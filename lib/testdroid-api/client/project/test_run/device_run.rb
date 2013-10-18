module TestdroidApi
  class Client
    class Project
      class TestRun
        class DeviceRun

          attr_reader :id, :device_id, :fail_message, :name, :state, :finished
          attr_reader :screenshots_url, :junit_url, :logs_url

          def initialize(client, run, config)
            @client     = client
            @project_id = run.project_id
            @run_id     = run.id

            update(config)
          end

          # Updates device run information
          def update!
            res_name = 'deviceRun'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}"

            config   = @client.get_api_request(endpoint, res_name)

            update(config)
          end

          # Get device run's test results as JUnit XML
          def junit_results
            res_name = 'junit XML'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}_junit.xml"

            @client.get_file(endpoint, res_name)
          end

          #Get device run's logs
          def logs
            res_name = 'log'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}_log.txt"

            @client.get_file(endpoint, res_name)
          end

          # Get device run's screenshots as a zip file.
          def screenshots_zip
            res_name = 'screenshots.zip'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}/screenshots.zip"

            @client.get_file(endpoint, res_name)
          end

          # Returns screenshots' ids for device run.
          def screenshots
            res_name = 'deviceRunScreenshots'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}/screenshots"

            @client.get_api_request(endpoint, res_name)
          end

          # Get device's run screenshot.
          # @param screenshot_id [Integer] screenshot id
          def screenshot(screenshot_id)
            res_name = 'screenshot'
            endpoint = "projects/#{@project_id}/runs/#{@run_id}/device-runs/#{id}/screenshots/#{screenshot_id}"

            @client.get_file(endpoint, res_name)
          end

          # Did test run finish
          def finished?
            finished
          end

          def results
            raise NotImplementedError
          end

          private
          def update(config)
            @id              = config['id']
            @device_id       = config['deviceId']
            @fail_message    = config['customerFailureMessage']
            @name            = config['deviceName']
            @state           = config['groupState']
            @finished        = config['finished']
            @screenshots_url = config['screenshotsURI']
            @junit_url       = config['junitURI']
            @logs_url        = config['logURI']
          end
        end
      end
    end
  end
end
