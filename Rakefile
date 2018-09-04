require_relative 'lib/gitlab_analyser'
require 'gitlab'
require 'yaml'

yaml = YAML.load_file('.gitlab-auth.yaml')

Gitlab.configure do |config|
  config.endpoint       = yaml["endpoint"]
  config.private_token  = yaml["private_token"]
end

desc "Get project id"
task :project_id do
  options = {
      project_namespace: ENV['project_namespace'],
      project_search: ENV['project']
  }
  p GitlabAnalyser.project_id options
end

desc "Analyse merge requests of a project"
task :analyse_merge_requests do
  p GitlabAnalyser.analyse_merge_requests(3818)
end

desc "Average response time of a merge request"
task :average_response_time do
  p GitlabAnalyser.average_response_time_in_merge_request(3818, 165)
end

