require 'gitlab'
require 'time'
require 'pry'

class GitlabAnalyser

  class << self

    def project_id(options)
      projects = Gitlab.project_search(options[:project_search])
      project = projects.find {|p| p.path_with_namespace == options[:project_namespace]}
      project.id
    end

    def analyse_merge_requests(project_id)
      merge_requests = Gitlab.merge_requests(project_id, {per_page: 100})
      merge_requests.each do |mr|
        p mr.title
        p average_response_time_in_merge_request(project_id, mr.iid)
      end
    end

    def average_response_time_in_merge_request(project_id, merge_request_id)
      merge_request = Gitlab.merge_request project_id, merge_request_id
      notes = Gitlab.merge_request_notes project_id, merge_request_id
      
      times = notes.map &:created_at
      times.push(merge_request.created_at)

      response_times = 0.upto(times.count - 2).map do |t|
        Time.parse(times[t]) - Time.parse(times[t + 1])
      end
      response_times.sum / response_times.size
    end
  end

end