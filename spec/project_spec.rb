require 'spec_helper'

describe TestdroidApi::Client::Project  do
  let(:auth_url) {"https://users.testdroid.com/api/v1/authorize"}
  let(:client)   { TestdroidApi::Client.new("username", "password") }

  let(:project_file) { File.new(File.dirname(__FILE__) + "/fixtures/new_project.json").read }
  let(:project)      { described_class.new(client, JSON.parse(project_file))}

  before do
    stub_request(:post, auth_url).
      to_return(:status => 200, :body => {"secretApiKey" => "1"}.to_json, :headers => {})
    client.authenticate!
  end

  context 'when authenticated' do
    describe '#delete' do
      let(:url) {"https://cloud.testdroid.com/api/v1/projects/232341/delete"}
      before do
        stub_request(:post, url).
          to_return(:status => 200, :body => {}.to_json, :headers => {})
      end
      it 'sends the right request' do
        project.delete!

        a_request(:post, url).should have_been_made
      end
    end

    describe '#upload_app_file' do
      let(:url) {"https://cloud.testdroid.com/api/v1/projects/232341/apks/application"}
      let(:apk_file_path) {File.dirname(__FILE__) + '/fixtures/app.apk'}

      before do
        stub_request(:post, url).
          to_return(:status => 200, :body => {}.to_json, :headers => {})
      end

      it 'sends the right request' do
        project.upload_app_file(apk_file_path)

        a_request(:post, url).should have_been_made
      end

      it 'ads Md5 to headers' do
        project.upload_app_file(apk_file_path)

        a_request(:post, url).with{ |request| request.headers.has_key? "X-Testdroid-Md5"  }.
          should have_been_made
      end
    end

    describe '#upload_test_file' do
      let(:url) {"https://cloud.testdroid.com/api/v1/projects/232341/apks/instrumentation"}
      let(:apk_file_path) {File.dirname(__FILE__) + '/fixtures/app.apk'}

      before do
        stub_request(:post, url).
          to_return(:status => 200, :body => {}.to_json, :headers => {})
      end

      it 'sends the right request' do
        project.upload_test_file(apk_file_path)

        a_request(:post, url).
          should have_been_made
      end
      it 'ads Md5 to headers' do
        project.upload_test_file(apk_file_path)

        a_request(:post, url).with{ |request| request.headers.has_key? "X-Testdroid-Md5"  }.
          should have_been_made
      end
      it 'sends the file' do
        project.upload_test_file(apk_file_path)

        a_request(:post, url).with(:body => /filename="app.apk"/).
          should have_been_made
      end
    end

    describe '#create_test_run' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/232341/run" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/new_run.json").read}
      before do
        stub_request(:post, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        project.create_test_run

        a_request(:post, url).should have_been_made
      end

      it 'creates new test run' do
        project.create_test_run.should be_kind_of TestdroidApi::Client::Project::TestRun
      end

      it 'adds default params' do
        project.create_test_run
        a_request(:post, url).
          with(:body => 'instatestMode=false&autoScreenshots=false&usedClusterId=all%20devices').should have_been_made
      end

      context 'with extra parameters' do
        let(:device_group) {double(TestdroidApi::Client::DeviceGroup)}
        before do
          device_group.stub(:id).and_return(1)
        end

        it 'sets proper device group' do
          project.create_test_run(device_group)

          a_request(:post, url).
            with(:body => 'instatestMode=false&autoScreenshots=false&usedClusterId=1').should have_been_made
        end
        it 'sets auto screen shots' do
          project.create_test_run(device_group, false,  true)

          a_request(:post, url).
            with(:body => 'instatestMode=false&autoScreenshots=true&usedClusterId=1').should have_been_made

        end
        it 'sets instatest mode' do
          project.create_test_run(device_group, true,  false)

          a_request(:post, url).
            with(:body => 'instatestMode=true&autoScreenshots=false&usedClusterId=1').should have_been_made
        end
      end
    end

    describe '#test_runs' do
      let(:url) { "https://cloud.testdroid.com/api/v1/projects/232341/runs" }
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/test_runs.json").read}

      before do
        stub_request(:get, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})

        TestdroidApi::Client::Project::TestRun.stub(:new).and_return(true)
      end

      it 'sends the right request' do
        project.test_runs

        a_request(:get, url).should have_been_made
      end
      it 'returns array of test runs' do
        project.test_runs.should == [true, true]
      end
    end

    describe '#config' do
      it 'is not implemented' do
        expect {project.config}.to raise_error(NotImplementedError)
      end
    end

    describe '#update_config' do
      it 'is not implemented' do
        expect {project.update_config({})}.to raise_error(NotImplementedError)
      end
    end
  end
end