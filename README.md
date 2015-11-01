# JiraStorm
A utility to sync JIRA issues to Stormboard.

## Installation
This gem isn't available on RubGems yet, so you'll need to install it from Artifactory:

```
gem install jirastorm --source https://artifactory.roving.com/gems
```

## Configuration
There are a number of ways to configure JiraStorm. You can pass configuration options to the command line, define them as environment variables, or place them in a configuration file, or any combination thereof.

### Options
| CLI Options | Configuration Option | Environment Variable |
| ------------- | -------------------- | -------------------- |
| config-file | | JIRASTORM_CONF |
| jira-issue-limit | jira_issue_limit | JIRA_ISSUE_LIMIT |
| jira-url | jira_url | JIRA_URL |
| jira-username | jira_username | JIRA_USERNAME |
| jira-password | jira_password | JIRA_PASSWORD |
| stormboard-url | stormboard_url | STORMBOARD_URL |
| stormboard-key | stormboard_key | STORMBOARD_KEY |
| storm-id | storm_id | STORM_ID |
| storm-key | storm_key | STORM_KEY |
| storm-name | storm_name | STORM_NAME |
| create-storm/no-create-storm | create_storm | |
| clean-storm/no-clean-storm | clean_storm | |
| log-level | log_level | JIRASTORM_LOG_LEVEL |
| log-destination | log_destination | JIRASTORM_LOG_DESTINATION |

### Command Line Options
```
Options:
  [--config-file=CONFIG_FILE]            # The path to a configuration file.
                                         # Default: ~/.jirastorm.rb
  [--jira-issue-limit=N]                 # The maximum number of JIRA issues to sync.
  [--jira-url=JIRA_URL]                  # The URL of your JIRA instance.
  [--jira-username=JIRA_USERNAME]        # Your JIRA username.
  [--jira-password=JIRA_PASSWORD]        # Your JIRA password.
  [--stormboard-url=STORMBOARD_URL]      # The URL of the Stormboard API.
                                         # Default: https://api.stormboard.com
  [--stormboard-key=STORMBOARD_KEY]      # The API key to use to conncet to Stormboard.
  [--storm-id=N]                         # The ID of the Storm to sync to.
  [--storm-key=STORM_KEY]                # The key of a Storm to join.
  [--storm-name=STORM_NAME]              # The name to give the newly created Storm.
  [--create-storm], [--no-create-storm]  # Create a new storm if one is not specified or found.
                                         # Default: true
  [--clean-storm], [--no-clean-storm]    # Remove all Storm ideas before syncing.
  [--log-level=LOG_LEVEL]                # The log level to output.
                                         # Default: info
  [--log-destination=LOG_DESTINATION]    # A file to log to.
```

### Configuration File Options
Most of the CLI options can be defined in a configuration file located at `~/.jirastorm.rb`. The configuration file is just a Ruby script so you can do all kinds of fun things. Here's an example of a configuration file that uses the `highline` gem to prompt the user for a password:

```
require 'highiline/import'

jira_url 'https://jira.example.com'
jira_username 'foo'
jira_password ask("Please enter your JIRA password:\n") { |q| q.echo = '*' }
stormboard_key 'supersecretstormboardkey'
storm_id '90210'
```

## Usage
The `jirastorm sync` command accepts a JQL query as an argument. The JIRA issues returned by that JQL query will be synced to Stormboard.

```
jirastorm sync 'project = SYS AND resolution = Unresolved ORDER BY updatedDate DESC'
```

The above example would sync all unresolved tickets in the SYS project in the descending order in which they were last updated. By default JIRA will only return the first 50 issues of a query. You can limit the number of tickets that get synced to Stormboard by using the `jira-issue-limit` option:

```
jirastorm sync --jira-issue-limit 10 'project = SYS AND resolution = Unresolved ORDER BY updatedDate DESC'
```
