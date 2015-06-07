module Dply
  module Strategy

    def self.load(config, options)
      require_relative "strategy/#{config.strategy}"
      const = "::Dply::Strategy::#{config.strategy.capitalize}"
      const = Module.const_get(const)

      # persist roles if DPLY_PERSIST_ROLES env is present
      # load roles from roles file
      roles = get_roles
      persist_roles(roles)

      return const.new(config, options)
    end

    private

    def self.persist_roles(roles)
      persist = ENV['DPLY_PERSIST_ROLES']
      return if not persist
      return if not roles
      Logger.logger.info  "persisting roles #{roles}"
      File.open('roles', 'w') { |f| f.write roles }
    end

    def self.get_roles
      ENV['DPLY_ROLES'] ||= roles_from_file
    end

    def self.roles_from_file
      if File.readable? "roles"
        File.read("roles").chomp.strip
      else
        nil
      end
    end


  end
end
