require_relative 'lib/gitlab_analyser'
require 'gitlab'
require 'yaml'

yaml = YAML.load_file('.gitlab-auth.yaml')

Gitlab.configure do |config|
  config.endpoint       = yaml["endpoint"]
  config.private_token  = yaml["private_token"]
end

desc "Show all dangling networks"
task :merge_requests do
  options = {
      project_namespace: ENV['project_namespace'],
      project_search: ENV['project']
  }

  p GitlabAnalyser.analyse_merge_requests(options)
end

task :average_response_time do
  p GitlabAnalyser.average_response_time_in_merge_request(3818, 165)
end

