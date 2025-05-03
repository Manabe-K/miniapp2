require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

require "dotenv/rails-now" if defined?(Dotenv)

module Myapp
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])
  end
end