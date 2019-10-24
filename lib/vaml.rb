require 'psych'
require 'yaml'
require 'vaml/config_handler'
require 'vaml/version'
require 'vaml/vault_config'
require 'vaml/configuration'
require 'vaml/railtie' if defined?(Rails)

module Vaml

  class << self
    attr_accessor :configuration

    # @param [Hash] options {host: '0.0.0.0:8200', token: ENV["VTOKEN"]}
    def configure(options)
      options[:host] ||= 'http://127.0.0.1:8200'
      options[:token] ||= ENV['VAULT_TOKEN']
      options[:ssl_verify] ||= false

      self.configuration ||= Configuration.new(options)
      yield configuration if block_given?

      # Configures Vault itself.
      Vaml::VaultConfig.configure!
      self
    end

    def write_values(key, hash_values)
      write(key, data: hash_values)
    end

    # Stores a value with a key named 'secret'
    def write_secret_string(key, value)
      write_values(key, secret: value)
    end

    # Reads a value where the key is named 'secret'
    def read_secret_string(key)
      read(key)[:secret]
    end

    def read_values(key)
      read(key)
    end

    def from_yaml(yml)
      handler = Vaml::ConfigHandler.new
      parser = Psych::Parser.new(handler)
      parser.parse(yml)
      handler.root.to_ruby.first
    end

    def read(query)
      Vault.with_retries(Vault::HTTPConnectionError) do
        val = Vault.logical.read(query)
        raise "VamlError: No secret was stored for #{query}" unless val

        val.data[:data] # 'data' is necessary for KV2 engine.
      end
    end

    def write(key, value)
      Vault.with_retries(Vault::HTTPConnectionError) do
        Vault.logical.write(key, value)
      end
    end
  end
end
