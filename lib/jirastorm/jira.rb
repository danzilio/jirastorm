require 'jirastorm/jira/issues'
require 'jira'

module JiraStorm
  module Jira
    def self.jira_client
      return @jira_client if @jira_client
      options = {}
      options[:username] = JiraStorm[:jira_username] if JiraStorm[:jira_username]
      options[:password] = JiraStorm[:jira_password] if JiraStorm[:jira_password]
      options[:auth_type] = :basic
      options[:site] = JiraStorm[:jira_url]
      options[:context_path] = ''

      @jira_client = ::JIRA::Client.new(options)
    end
  end
end
