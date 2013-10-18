require 'spec_helper'

describe TestdroidApi::Client::Project::TestRun::DeviceRun  do

  let(:auth_url) { "https://users.testdroid.com/api/v1/authorize" }
  let(:client)   { TestdroidApi::Client.new('username', 'password') }
  let(:run)      { double(TestdroidApi::Client::Project::TestRun) }
  let(:config)   { JSON.parse(File.new(File.dirname(__FILE__) + "/fixtures/device_run.json").read)}
  before do
    stub_request(:post, auth_url).
      to_return(:status => 200, :body => {"secretApiKey" => "1"}.to_json, :headers => {})
    client.authenticate!

    run.stub(:project_id).and_return(1)
    run.stub(:id).and_return(100)
  end

  context 'when authenticated' do
    let(:device_run) { described_class.new(client, run, config) }

    describe '#update!' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/100/device-runs/1000" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/waiting_device_run.json").read}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        device_run.update!

        a_request(:get, url).
          should have_been_made
      end

      it 'updates run state' do
        device_run.update!
        device_run.state.should == "WAITING"
      end
    end


    describe '#finished' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/100/device-runs/1000" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/waiting_device_run.json").read}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'returns true when run is finished' do
        device_run.should be_finished
      end

      it 'returns false when run it not finished' do
        device_run.update!
        device_run.should_not be_finished
      end
    end

    describe '#logs_zip' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/100/device-runs/1000_log.txt" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/logs.txt")}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => response_body, :headers => {})
      end

      it 'sends the right request' do
        device_run.logs

        a_request(:get, url).should have_been_made
      end

    end

    describe '#screenshots_zip' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/100/device-runs/1000/screenshots/1000" }

      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'sends the right request' do
        device_run.screenshot(1000)

        a_request(:get, url).should have_been_made
      end

    end

    describe '#junit_results' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/1/runs/100/device-runs/1000_junit.xml" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/junit.xml")}
      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => response_body, :headers => {})
      end

      it 'sends the right request' do
        device_run.junit_results

        a_request(:get, url).should have_been_made
      end
    end
  end
end