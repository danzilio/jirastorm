require 'jirastorm/stormboard'

module JiraStorm
  module Stormboard
    class Storm
      attr_reader :title, :id

      def self.load
        if JiraStorm[:storm_id] && JiraStorm[:storm_key]
          JiraStorm.log.debug "Joining existing Storm ##{JiraStorm[:storm_id]}"
          Stormboard.post 'storms/join', stormid: JiraStorm[:storm_id], storm_key: JiraStorm[:storm_key]
        elsif JiraStorm[:create_storm] && !JiraStorm[:storm_id]
          title = JiraStorm[:storm_name] || 'JiraStorm'
          JiraStorm.log.debug "Creating Storm with name #{title}"
          response = Stormboard.post 'storms', title: title
          JiraStorm[:storm_id] = response['id']
          JiraStorm.log.debug "Created Storm with name #{title} and ID ##{JiraStorm[:storm_id]}"
          JiraStorm.log.info "Newly created Storm available at: https://stormboard.com/storm/#{JiraStorm[:storm_id]}"
        end

        storm = Stormboard.get "storms/#{JiraStorm[:storm_id]}"
        storm = storm['storm']
        new(id: JiraStorm[:storm_id], title: storm['title'])
      end

      def initialize(**config)
        @title = config[:title]
        @id = config[:id]
      end

      def purge_ideas
        ideas.each(&:delete!)
        @ideas = nil
      end

      def new_idea(content)
        idea = JiraStorm::Stormboard::Idea.create(self.id, content)
        @ideas << idea
        return idea
      end

      def ideas
        return @ideas if @ideas
        ideas = Stormboard.get("storms/#{id}/ideas")['ideas']
        @ideas = ideas.map { |i| JiraStorm::Stormboard::Idea.new(id: i['id'], content: i['data']['text'], color: i['color'], storm: self.id) }
      end
    end
  end
end
