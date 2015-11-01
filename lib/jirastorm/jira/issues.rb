require 'jirastorm/jira'

module JiraStorm
  module Jira
    class Issues
      attr_reader :key, :id, :description, :summary

      def self.find(query)
        issues = []
        JiraStorm.log.debug "JIRA Issue limit set to #{JiraStorm[:jira_issue_limit]}, limiting query to #{JiraStorm[:jira_issue_limit]} issues." if JiraStorm[:jira_issue_limit]
        JiraStorm::Jira.jira_client.Issue.jql(query, {max_results: JiraStorm[:jira_issue_limit]}).each do |i|
          issues << self.new(key: i.key, summary: i.summary, description: i.description)
        end
        issues
      end

      def initialize(**data)
        @id = data[:id]
        @key = data[:key]
        @description = data[:description]
        @summary = data[:summary]
      end

      def to_s
        fields = [key, summary]
        fields << description if description

        fields.join("\n")
      end
    end
  end
end
