require 'mixlib/config'
require 'logger'

module JiraStorm
  extend Mixlib::Config
  config_strict_mode true

  configurable :config_file
  configurable :jira_issue_limit
  configurable :jira_url
  configurable :jira_username
  configurable :jira_password
  configurable :stormboard_url
  configurable :stormboard_key
  configurable :storm_id
  configurable :storm_key
  configurable :storm_name
  configurable :create_storm
  configurable :clean_storm
  default :log_destination, STDOUT
  configurable :log_level

  def self.log
    return @logger if @logger
    @logger = Logger.new(JiraStorm.log_destination)
    @logger.level = Logger.const_get log_level.upcase
    return @logger
  end

  def self.sync(jira_issues, storm)
    storm_ideas = storm.ideas.map(&:content)
    jira_issues.each do |issue|
      unless storm_ideas.include?(issue.to_s)
        idea = storm.new_idea(issue.to_s)
        log.info "JIRA issue #{issue.key} created as Idea ##{idea.id} in Storm ##{JiraStorm[:storm_id]}"
      end
    end
  end
end
