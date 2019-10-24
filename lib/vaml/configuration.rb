module Vaml
  class Configuration
    attr_accessor :host, :token, :ssl_verify
    def initialize(options)
      @host = options[:host]
      @token = options[:token]
      @ssl_verify = options[:ssl_verify]
    end
  end
end
