require 'spec_helper'
describe TestdroidApi::Client::Project::TestRun  do
  let(:auth_url) { "https://users.testdroid.com/api/v1/authorize" }
  let(:project)  { double(TestdroidApi::Client::Project) }
  let(:client)   { TestdroidApi::Client.new('username', 'password') }

  before do
    stub_request(:post, auth_url).
      to_return(:status => 200, :body => {"secretApiKey" => "1"}.to_json, :headers => {})
    client.authenticate!
    project.stub(:id).and_return(1)
  end

  context 'when authenticated' do
    let(:run_config)   { JSON.parse(File.new(File.dirname(__FILE__) + "/fixtures/new_run.json").read)}
    let(:test_run)     { described_class.new(client, project, run_config) }

    describe '#update!' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/finished_run.json").read}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        test_run.update!

        a_request(:get, url).
          should have_been_made
      end

      it 'updates run state' do
        test_run.update!
        test_run.state.should == "FINISHED"
      end

      it 'updates run name' do
        test_run.update!
        test_run.name.should == "Renamed"
      end
    end

    describe '#device_runs' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176/device-runs" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/device_runs.json").read}

      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        test_run.device_runs

        a_request(:get, url).should have_been_made
      end

      it 'returns array of DeviceRuns' do
        TestdroidApi::Client::Project::TestRun::DeviceRun.stub(:new).and_return(true)

        test_run.device_runs.should == [true, true, true]
      end
    end

    describe '#finished' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/finished_run.json").read}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'returns false when run it not finished' do
        test_run.should_not be_finished
      end

      it 'returns true when run is finished' do
        test_run.update!
        test_run.should be_finished
      end
    end

    describe '#logs_zip' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176/logs.zip" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/logs.zip")}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => response_body, :headers => {})
      end

      it 'sends the right request' do
        test_run.logs_zip

        a_request(:get, url).should have_been_made
      end

      it 'does not JSON parse response' do
        client = double(client)
        client.should_receive(:get_file).with(any_args)

        run = TestdroidApi::Client::Project::TestRun.new(client, project, {})
        run.logs_zip
      end
    end

    describe '#screenshots_zip' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176/screenshots.zip" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/logs.zip")}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => response_body, :headers => {})
      end

      it 'sends the right request' do
        test_run.screenshots_zip

        a_request(:get, url).should have_been_made
      end

      it 'does not JSON parse response' do
        client = double(client)
        client.should_receive(:get_file).with(any_args)

        run = TestdroidApi::Client::Project::TestRun.new(client, project, {})
        run.screenshots_zip
      end
    end

    describe '#junit_results_zip' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/10176/junits.zip" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/logs.zip")}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => response_body, :headers => {})
      end

      it 'sends the right request' do
        test_run.junit_results_zip

        a_request(:get, url).should have_been_made
      end

      it 'does not JSON parse response' do
        client = double(client)
        client.should_receive(:get_file).with(any_args)

        run = TestdroidApi::Client::Project::TestRun.new(client, project, {})
        run.junit_results_zip
      end
    end

    describe '#results' do
      it 'is not implemented' do
        expect {test_run.results}.to raise_error(NotImplementedError)
      end
    end
  end
end