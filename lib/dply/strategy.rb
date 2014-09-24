module Dply
  module Strategy

    def self.load(config, options)
      require_relative "strategy/#{config.strategy}"
      const = "::Dply::Strategy::#{config.strategy.capitalize}"
      const = Module.const_get(const)
      return const.new(config, options)
    end

  end
end
