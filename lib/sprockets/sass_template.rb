require 'tilt'
require 'sprockets/sass_importer'

module Sprockets
  # This custom Tilt handler replaces the one built into Tilt. The
  # main difference is that it uses a custom importer that plays nice
  # with sprocket's caching system.
  #
  # See `SassImporter` for more infomation.
  class SassTemplate < Tilt::Template
    self.default_mime_type = 'text/css'

    def self.engine_initialized?
      defined? ::Sass::Engine
    end

    def initialize_engine
      require_template_library 'sass'
    end

    def prepare
    end

    def syntax
      :sass
    end

    def evaluate(context, locals, &block)
      # Use custom importer that knows about Sprockets Caching
      importer = SassImporter.new(context)
      cache_store = SassCacheStore.new(context.environment)

      options = {
        :filename => eval_file,
        :line => line,
        :syntax => syntax,
        :cache_store => cache_store,
        :importer => importer,
        :load_paths => [importer]
      }

      ::Sass::Engine.new(data, options).render
    rescue ::Sass::SyntaxError => e
      # Annotates exception message with parse line number
      context.__LINE__ = e.sass_backtrace.first[:line]
      raise e
    end
  end
end
