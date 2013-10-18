require 'spec_helper'

describe TestdroidApi::Client do
  let(:client_class) { described_class }
  let(:client) {client_class.new("user", "password")}

  let(:auth_url) {"https://users.testdroid.com/api/v1/authorize"}
  before do
    stub_request(:post, auth_url).
      to_return(:status => 200, :body => {"secretApiKey" => "1"}.to_json, :headers => {})
  end

  describe '#authenticate' do
    it 'sends the right request' do
      client.authenticate!

      a_request(:post, auth_url).
        with(:body => {:email => "user", :password => "password" }).
        should have_been_made
    end

    context 'when successful' do
      it 'stores apiKey' do
        client.authenticate!

        client.instance_variable_get('@api_key').should == '1'
      end
    end

    context 'when fails' do
      it 'throws exception' do
        stub_request(:post, "https://users.testdroid.com/api/v1/authorize").
          to_return(:status => 200, :body => {}.to_json, :headers => {})

        expect { client.authenticate! }.
          to raise_error(RuntimeError, "Could not authenticate, are you sure you have the right credentials?")
      end
    end
  end

  context 'when authenticated' do
    before do
      client.authenticate!
    end

    describe '#projects' do
      let(:url) {"https://cloud.testdroid.com/api/v1/projects"}
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/projects.json").read}

      before do
        stub_request(:get, url).
          to_return(:body => JSON.parse(response_body).to_json)
      end

      it 'sends the right request' do
        client.projects

        a_request(:get, url).should have_been_made
      end

      context 'without any params' do
        it 'should return array of projects' do
          TestdroidApi::Client::Project.stub(:new).with(any_args).and_return(true)

           client.projects.should == [true, true]
        end
      end

      context 'with project names' do
        it 'finds the matching projects' do
          client.projects('Project 1').first.name.should == "Project 1"
        end
        it 'removes unmatched projects' do
          client.projects('Project 1').count.should == 1
        end
      end
    end

    describe '#create_project' do
      let(:url) {"https://cloud.testdroid.com/api/v1/projects"}
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/new_project.json").read}
      before do
        stub_request(:post, url).
          to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        client.create_project("Name", "Description" )

        a_request(:post, url).
          with(:body => {:name => "Name", :description => "Description"}  ).
          should have_been_made
      end

      it 'returns new project' do
        client.create_project(nil, nil).name.should == "New project name"
      end
    end

    describe '#device groups' do
      let(:url) {url = "https://cloud.testdroid.com/api/v1/clusters"}
      let(:response_body) {File.new(File.dirname(__FILE__) + "/fixtures/devices.json").read}
      before do
        stub_request(:get, url).
         to_return(:status => 200, :body => JSON.parse(response_body).to_json, :headers => {})
      end

      it 'sends the right request' do
        client.device_groups

        a_request(:get, url).
          should have_been_made
      end

      context 'without params' do
        it 'returns all device groups' do
          client.device_groups("Test devices").first.display_name.should == "Test devices"
        end

        it 'removes unmatched projects' do
          client.device_groups("Test devices").count.should == 1
        end
      end

    end
  end

  context 'when not authenticated' do
    it 'does not allow to fetch projects' do
      expect{client.projects}.
        to raise_error(RuntimeError, "Are you sure you've authenticated?")
    end
  end
end