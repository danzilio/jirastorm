require 'jirastorm/jira'

module JiraStorm
  module Jira
    class Issues
      attr_reader :data
      def self.find(query)
        issues = []
        JiraStorm::Jira.jira_client.Issue.jql(query).each do |i|
          issues << self.new(key: i.key, summary: i.summary, description: i.description)
        end
        issues
      end

      def initialize(**data)
        @data = data
      end

      def method_missing(method_symbol)
        data[method_symbol]
      end

      def to_s
        fields = [data[:key], data[:summary]]
        fields << data[:description] if data[:description]

        fields.join("\n")
      end
    end
  end
end
