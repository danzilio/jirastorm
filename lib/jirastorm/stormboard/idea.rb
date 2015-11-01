require 'jirastorm/stormboard'

module JiraStorm
  module Stormboard
    class Idea
      attr_accessor :id, :content, :color, :storm

      def self.create(storm, content)
        response = Stormboard.post 'ideas', stormid: storm, data: content
        JiraStorm.log.debug "Created Idea ##{response['id']} in Storm ##{storm}"
        new(storm: storm, id: response['id'], data: content)
      end

      def initialize(**config)
        @storm = config[:storm]
        @id = config[:id]
        @content = config[:content]
        @color = config[:color]
      end

      def delete!
        JiraStorm.log.debug "Deleting Idea: #{id} from Storm ##{storm}"
        Stormboard.delete "ideas/#{id}"
        return
      end

      def to_h
        {
          id: id,
          content: content,
          color: color
        }
      end

      def to_s
        to_h.to_s
      end
    end
  end
end
