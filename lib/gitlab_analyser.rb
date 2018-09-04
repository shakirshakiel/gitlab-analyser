require 'gitlab'
require 'time'
require 'pry'

class GitlabAnalyser

  class << self
    def analyse_merge_requests(options)
      projects = Gitlab.project_search(options[:project_search])
      project = projects.find {|p| p.path_with_namespace == options[:project_namespace]}
      merge_requests = Gitlab.merge_requests(project.id, {per_page: 100})
      merge_request_ids = merge_requests.map {|mr| mr.iid}
      merge_request_ids.each do |mr_id|
        notes = Gitlab.merge_request_notes project.id, mr_id
        times = notes.map &:created_at
        response_times = 0.upto(times.count - 2).map do |t|
          Time.parse(times[t]) - Time.parse(times[t + 1])
        end
        response_times.sum / response_times.size
      end
    end

    def average_response_time_in_merge_request(project_id, merge_request_id)
      notes = Gitlab.merge_request_notes project_id, merge_request_id
      times = notes.map &:created_at
      response_times = 0.upto(times.count - 2).map do |t|
        Time.parse(times[t]) - Time.parse(times[t + 1])
      end
      response_times.sum / response_times.size
    end
  end

end