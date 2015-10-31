module Stormboard
  class Idea
    def initialize(stormid, **config)
      @data = defaults.merge(config)
      @data[:stormid] = stormid
    end

    def defaults
      {
        :color => 'yellow',
        :lock => 0
      }
    end

    def to_json
      @data.to_json
    end
  end
end
