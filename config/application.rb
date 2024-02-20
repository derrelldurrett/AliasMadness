require_relative 'boot'

require 'rails/all'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AliasMadness
  @name = %q(Alia's Madness)
  @start_time = DateTime.current
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller
    config.load_defaults 7.0

    # Settoad the plugins named here, in the order given (default is alphabetical).
    #     # :all canings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #config.force_ssl=true

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W(#{config.root}/lib/assets/errors) # was .eager_load_paths

    # Only l be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Mountain Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # include the root (so we know what we're recreating/
    # serializing in the code)
    config.active_record.include_root_in_json = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # prevent asset:precompile from running the initializers, in theory.
    config.assets.initialize_on_precompile = false

    # We use delayed_job_active_record to determine, in the background, which players
    # will benefit if a specific group of winning teams win out.
    config.active_job.queue_adapter = :delayed_job

    config.active_record.legacy_connection_handling = false

    config.after_initialize do
      ActiveRecord.yaml_column_permitted_classes += [LabelLookup, Game, Team]
    end
  end

  #TODO try to initialize here?
  def self.init_brackets

  end
end

AliasMadness