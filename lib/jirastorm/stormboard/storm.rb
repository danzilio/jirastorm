module Stormboard
  class Storm
    attr_accessor :data

    def self.find(needle, status: active)
      Stormboad.get('storms', needle: needle, status: active)
    end

    def self.save
      Stormboard.post('storms', self.data)
    end

    def initialize(title, **config)
      @data = defaults.merge(config)
      @data[:title] = title
    end

    def defaults
      {
        :description => nil,
        :template => nil,
        :votesperuser => 10,
        :avatars => 1,
        :ideacreator => 1
      }
    end
  end
end
