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

    def seconds_in_words(seconds)
      return 0 if seconds < 0
      case
          when seconds < 100    then seconds.round(2)
          when seconds < 3600   then "#{(seconds / 60).round(2)} minutes"
          when seconds < 216000 then "#{(seconds / 3600).round(2)} hours"
      end
    end

    def analyse_merge_requests(project_id, usernames)
      merge_requests = Gitlab.merge_requests(project_id, {per_page: 100})
      mrs_of_interest = merge_requests.select {|mr| usernames.include? mr.author.username }
      mrs_of_interest.each do |mr|
        p "#{mr.title}, #{seconds_in_words(average_response_time_in_merge_request(project_id, mr.iid))}"
      end
    end

    def average_response_time_in_merge_request(project_id, merge_request_id)
      merge_request = Gitlab.merge_request project_id, merge_request_id
      notes = Gitlab.merge_request_notes project_id, merge_request_id, {per_page: 100}
      
      times = notes.map &:created_at
      times.push(merge_request.created_at)

      response_times = 0.upto(times.count - 2).map do |t|
        Time.parse(times[t]) - Time.parse(times[t + 1])
      end
      return 0 if response_times.empty?

      response_times.sum / response_times.size
    end

    def analyse_merge_requests_of_users(project_id, usernames)
      merge_requests = Gitlab.merge_requests(project_id, {per_page: 100})
      mrs_of_interest = merge_requests.select {|mr| usernames.include? mr.author.username }
      response_times = mrs_of_interest.map do |mr|
        average_response_time_in_merge_request_of_users(project_id, mr.iid, usernames)
      end
      response_times.sum / response_times.size
    end

    def average_response_time_in_merge_request_of_users(project_id, merge_request_id, usernames)
      merge_request = Gitlab.merge_request project_id, merge_request_id
      notes = Gitlab.merge_request_notes project_id, merge_request_id, {per_page: 100}
      
      response_times = []
      input = [notes, merge_request].flatten

      0.upto(input.count - 2) do |t|
        if !usernames.include?(input[t].author.username)
          t1 = Time.parse(input[t].created_at)
          t2 = Time.parse(input[t + 1].created_at)
          response_times << t1 - t2
        end  
      end

      return 0 if response_times.empty?
      response_times.sum / response_times.size
    end

    def total_interactions(project_id, usernames)
      merge_requests = Gitlab.merge_requests(project_id, {per_page: 100})
      mrs_of_interest = merge_requests.select {|mr| usernames.include? mr.author.username }
      interactions = mrs_of_interest.map {|mr| total_interactions_in_merge_request(project_id, mr.iid) }
      interactions.sum
    end

    def total_interactions_in_merge_request(project_id, merge_request_id)
      merge_request = Gitlab.merge_request project_id, merge_request_id
      notes = Gitlab.merge_request_notes project_id, merge_request_id, {per_page: 100}
      notes.count
    end

  end

end