module TestdroidApi
  class Client
    class DeviceGroup

      attr_reader :id, :name, :display_name, :count, :price, :coverage
      def initialize(client, config)
        @client       = client
        @id           = config['id']
        @name         = config['name']
        @display_name = config['displayName']
        @count        = config['deviceCount']
        @price        = config['creditsPrice']
        @coverage     = config['coverage']
      end

    end
  end
end
