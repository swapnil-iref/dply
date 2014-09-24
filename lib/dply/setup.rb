module Dply
  module Setup

    def self.load(strategy, config)
      require_relative "setup/#{strategy}"
      const = "::Dply::Setup::#{strategy.capitalize}"
      const = Module.const_get(const)
      return const.new(config)
    end

  end
end
