module Autobots
  module Helpers
    module Caching
      DEFAULT_CACHE_KEY = -> (object, _) {
        object.cache_key
      }

      def initialize(_, options = {})
        super
        @cache = options[:cache]
      end

      def data
        return @data if defined?(@data)

        if @cache
          key_proc = options.fetch(:cache_key, DEFAULT_CACHE_KEY)
          identifiers = objects.inject({}) do |acc, obj|
            acc[key_proc.call(obj, self)] = obj
            acc
          end

          # misses: { key => obj }
          @data = BulkCacheFetcher.new(@cache).fetch(identifiers) do |misses|
            roll_out(misses.values)
          end
        else
          @data = super
        end
        @data
      end
    end
  end
end