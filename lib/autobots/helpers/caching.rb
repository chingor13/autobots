module Autobots
  module Helpers
    module Caching
      extend ActiveSupport::Concern

      def initialize(_, options = {})
        super
        self.cache = options[:cache] if options.has_key?(:cache)
      end

      def self.prepended(klass)
        klass.class_eval do
          class_attribute :cache
        end
      end

      def data
        return @data if defined?(@data)

        if cache
          key_proc = options.fetch(:cache_key) do
            method(:cache_key)
          end
          identifiers = objects.inject({}) do |acc, obj|
            acc[key_proc.call(obj, self)] = obj
            acc
          end

          # misses: { key => obj }
          @data = BulkCacheFetcher.new(cache).fetch(identifiers) do |misses|
            roll_out(misses.values)
          end
        else
          @data = super
        end
        @data
      end

      protected

      def cache_key(object, _)
        [object.cache_key, serializer.name, 'serializable-hash']
      end
    end
  end
end