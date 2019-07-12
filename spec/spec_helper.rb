# frozen_string_literal: true

require 'rspec'
require 'pry'
require_relative '../lib/testrail-kit'

client = nil
project = nil
test_case = nil
section = nil

RSpec.configure do |config|
  config.before(:suite) do
    client = TestRail::Client.new
    project = client.add_project(name: 'Project name created by rspec', suite_mode: 1)
    section = client.add_section(project['id'], name: 'Section name created by rspec')
    test_case = client.add_case(section['id'], title: 'Title name created by rspec')
  end

  config.around(:example) do |example|
    example.metadata[:project_id] = project['id']
    example.metadata[:section_id] = section['id']
    example.metadata[:case_id] = test_case['id']
    example.run
  end

  config.after(:suite) do
    client.delete_project(project['id']) if project
  end
end
