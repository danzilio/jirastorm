require 'thor'

module JiraStorm
  class CLI < Thor
    class_option :config_file,
      :type => :string,
      :default => ENV['CONFIG_FILE'] || '/etc/jirastorm/config.yaml',
      :desc => 'The path to a configuration file.'
    class_option :jira_url,
      :type => :string,
      :default => ENV['JIRA_URL'],
      :desc => "The URL of your JIRA instance. This should be the base url to your JIRA instance's API."
    class_option :jira_key,
      :type => :string,
      :default => ENV['JIRA_KEY'],
      :desc => 'The JIRA API key.'
    class_option :jira_secret,
      :type => :string,
      :default => ENV['JIRA_SECRET'],
      :desc => 'The JIRA API secret.'
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
      :desc => "The Storm ID for the storm you'd like to sync to. This Storm must exist."
    class_option :storm_key,
      :type => :string,
      :default => ENV['STORM_KEY'],
      :desc => "The Storm key for the Storm you'd like to sync to. This Storm must exist."
    class_option :storm_name,
      :type => :string,
      :default => ENV['STORM_NAME'],
      :desc => "The name of the Storm to sync to. If this Storm doesn't exist and create_storm is set to true, a Storm with this name will be created."
    class_option :create_storm,
      :type => :boolean,
      :default => true,
      :desc => 'Create a new storm if one is not specified or found.'

    desc "sync <jira_query>", "Syncs the issues returned by <jira_query> to Stormboard."
    long_desc <<-LONGDESC
      Runs the <jira_query> JQL and syncs the issues to Stormboard. Note that
      the search is already confined to issues in JIRA.

      If no Storm is specified using the --storm_id and --storm_key options, or
      with the --storm_name option, a Storm will be created for you. If you
      specify a --storm_name but no Storm with that name is found, one with that
      name will be created. This behavior is configurable via the --create_storm
      option.

      You must supply the --stormboard_key, --jira_url, --jira_key, and
      --jira_secret parameters, or these must be configured in your
      configuration file and specified with the --config_file option.
      Alternatively, you can specify values for these options using environment
      variables by setting STORMBOARD_KEY, JIRA_URL, JIRA_KEY, and JIRA_SECRET.

      Command line arguments are given precedence for configuration, followed by
      environment variables, then configuration file parameters.
    LONGDESC
    def sync(jira_query)
      config = get_config(options)
    end

    # Command line arguments are given precedence for configuration, followed by
    # environment variables, then configuration file parameters.
    #
    def get_config(options)
      environment_variables = %w[
        STORMBOARD_URL,
        STORMBOARD_KEY,
        JIRA_URL,
        JIRA_KEY,
        JIRA_SECRET,
        STORM_ID,
        STORM_KEY,
        STORM_NAME,
      ]

      env_config = {}

      environment_variables.each do |v|
        env_config[v.downcase.to_sym] = ENV[v] if ENV[v]
      end

      config_file = YAML.load_file(options[:config_file]) if File.exist?(options[:config_file]) || {}

      config_file.merge(env_config).merge(options)
    end
  end
end
