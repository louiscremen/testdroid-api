[![Gem Version](https://badge.fury.io/rb/testdroid-api.png)](http://badge.fury.io/rb/testdroid-api)
[![Build Status](https://travis-ci.org/soundcloud/testdroid-api.png)](https://travis-ci.org/soundcloud/testdroid-api)
[![Coverage Status](https://coveralls.io/repos/soundcloud/testdroid-api/badge.png?branch=master)](https://coveralls.io/r/soundcloud/testdroid-api?branch=master)
# Testdroid-api

The testdroid-api gem is a client for the [Testdroid Cloud API](http://docs.testdroid.com/_pages/client.html).

## Installing

In your application's Gemfile, add `gem 'testdroid-api'`. Then, execute the following command:

    $ bundle

Alternatively, you can install it yourself:

    $ gem install testdroid-api

## Using

The testdroid-api gem allows you to create, manage, and delete projects on testdroid Cloud.
For each project, you can trigger a test run. You can get collective or device-specific test results.

### Authentication
```ruby
require 'testdroid-api'

client = TestdroidApi::Client.new('user_email', 'password')
client.authenticate!
=> "api_token"
```

### TestDroid projects
```ruby
project = client.projects.first

# create new project
client.create_project('Name', 'Description')
=> <TestdroidApi::Client::Project @name=Name, @description=Description>

# list all projects
client.projects
=> [
    <TestdroidApi::Client::Project>,
    <TestdroidApi::Client::Project>
   ]

# find projects by name
client.projects('Name')
=> [ <TestdroidApi::Client::Project, @name=Name> ]

# delete project
project.delete!

# upload application
project.upload_app_file(absolute_path_to_application)

# upload instrumentation
project.upload_test_file(absolute_path_to_tests)
```

### TestDroid test runs
```ruby
project = client.projects.first
run     = project.test_runs.first

# list all test runs
project.test_runs
=> [
    <TestdroidApi::Client::Project::TestRun> ,
    <TestdroidApi::Client::Project::TestRun>
   ]

# create new test run
project.create_test_run
=> <TestdroidApi::Client::Project::TestRun>

# update test run state
run.update!
=> <TestdroidApi::Client::Project::TestRun>

# get test run's results as junit xml (zip)
File.open(path_to_file, 'w') { |file| file.write(run.junit_results_zip) }

# get test run's screenshots (zip)
File.open(path_to_file, 'w') { |file| file.write(run.screenshots_zip) }

# get test run's logs (zip)
File.open(path_to_file, 'w') { |file| file.write(run.logs_zip) }

# get test run results
run.results
=> NotImplemented
```

### TestDroid device runs
```ruby
project    = client.projects.first
run   	   = project.test_runs.first
device_run = run.device_runs.first

# get device runs
run.device_runs
=> [
    <TestdroidApi::Client::Project::TestRun::DeviceRun>,
    <TestdroidApi::Client::Project::TestRun::DeviceRun>
   ]

# get device's results as junit xml
File.open(path_to_file, 'w') { |file| file.write(device_run.junit_results) }

# get device's logs
device_run.logs

# list device's screenshots
device_run.screenshots
=> [ { "id": 108144 }, { "id": 108145 } ]

# get a specific screenshot
File.open(path_to_file, 'w') { |file| file.write(device_run.screenshot(108144)) }

# get device run results
device_run.results
=> NotImplemented
```

## Contributing

1. Fork it.
2. Create a feature branch (`git checkout -b <my-feature-branch>`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Run tests (`rspec`).
5. Push your changes to the feature branch (`git push origin <my-feature-branch>`).
6. Create a new pull request.

Thanks to [@soundcrowd-ursula](https://github.com/soundcrowd-ursula) for making this doc prettier. 
