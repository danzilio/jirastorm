require 'thor'
require 'yaml'
require 'jirastorm'
require 'jirastorm/jira'
require 'jirastorm/stormboard'

module JiraStorm
  class CLI < Thor
    class_option :config_file,
      :type => :string,
      :default => ENV['JIRASTORM_CONF'] || File.expand_path('~/.jirastorm.rb'),
      :desc => 'The path to a configuration file.'
    class_option :jira_issue_limit,
      :type => :numeric,
      :default => ENV['JIRA_ISSUE_LIMIT'],
      :desc => 'The maximum number of JIRA issues to sync.'
    class_option :jira_url,
      :type => :string,
      :default => ENV['JIRA_URL'],
      :desc => "The URL of your JIRA instance."
    class_option :jira_username,
      :type => :string,
      :default => ENV['JIRA_USERNAME'],
      :desc => 'Your JIRA username.'
    class_option :jira_password,
      :type => :string,
      :default => ENV['JIRA_PASSWORD'],
      :desc => 'Your JIRA password.'
    class_option :stormboard_url,
      :type => :string,
      :default => ENV['STORMBOARD_URL'] || 'https://api.stormboard.com',
      :desc => 'The URL of the Stormboard API.'
    class_option :stormboard_key,
      :type => :string,
      :default => ENV['STORMBOARD_KEY'],
      :desc => 'The API key to use to conncet to Stormboard.'
    class_option :storm_id,
      :type => :numeric,
      :default => ENV['STORM_ID'],
      :desc => "The Storm ID for the storm you'd like to sync to."
    class_option :storm_key,
      :type => :string,
      :default => ENV['STORM_KEY'],
      :desc => "The key of a Storm to join."
    class_option :storm_name,
      :type => :string,
      :default => ENV['STORM_NAME'],
      :desc => "The name to give the newly created Storm."
    class_option :create_storm,
      :type => :boolean,
      :default => true,
      :desc => 'Create a new storm if one is not specified or found.'
    class_option :clean_storm,
      :type => :boolean,
      :default => false,
      :desc => 'Remove all Storm ideas before syncing.'
    class_option :log_level,
      :type => :string,
      :default => ENV['JIRASTORM_LOG_LEVEL'] || 'info',
      :desc => 'The log level to output.'
    class_option :log_destination,
      :type => :string,
      :default => ENV['JIRASTORM_LOG_DESTINATION'],
      :desc => 'A file to log to.'

    desc "sync <jira_query>", "Syncs the issues returned by <jira_query> to Stormboard."
    long_desc <<-LONGDESC
      Runs the <jira_query> JQL and syncs the issues to Stormboard. Note that
      the search is already confined to 'issues' in JIRA.

      If no Storm is specified using the --storm_id option a Storm will be
      created for you. If you'd like to join an existing Storm, you must provide
      the --storm_id and --storm_key options.

      You must supply the --stormboard_key, --jira_url, --jira_username, and
      --jira_password parameters, or these must be configured in your
      configuration file and specified with the --config_file option.
      Alternatively, you can specify values for these options using environment
      variables by setting STORMBOARD_KEY, JIRA_URL, JIRA_USERNAME, and
      JIRA_PASSWORD.

      Command line arguments are given precedence for configuration, followed by
      environment variables, then configuration file parameters.
    LONGDESC
    def sync(jira_query)
      load_config
      issues = JiraStorm::Jira::Issues.find(jira_query)
      JiraStorm.log.info "Query returned #{issues.count} issues from JIRA"
      storm = JiraStorm::Stormboard::Storm.load
      JiraStorm.log.info "Found #{storm.ideas.count} ideas in Storm ##{JiraStorm[:storm_id]}"
      JiraStorm.log.debug "The clean_storm option is set, purging all existing Ideas from Storm ##{JiraStorm[:storm_id]}."
      storm.purge_ideas if JiraStorm[:clean_storm]
      JiraStorm.sync(issues, storm)
      JiraStorm.log.info "Sync complete! Access your storm at https://stormboard.com/storm/#{JiraStorm[:storm_id]}"
    end

    no_commands do
      def load_config
        required = [
          :jira_url,
          :jira_username,
          :jira_password,
          :stormboard_url,
          :stormboard_key
        ]

        JiraStorm.from_file(options[:config_file]) if options[:config_file] && File.exist?(options[:config_file])

        options.each do |o,v|
          JiraStorm.send("#{o}=", v)
        end

        not_supplied = required - JiraStorm.keys

        unless not_supplied.empty?
          puts "ERROR: Missing required configuration options: #{not_supplied.join(', ')}.\n\n"
          help
          exit 1
        end

        return
      end
    end
  end
end
