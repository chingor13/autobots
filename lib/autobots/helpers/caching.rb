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

          if options[:force_reload]
            identifiers.each do |identifier|
              cache.delete identifier
            end
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

      def serializer_cache_key
        return @serializer_cache_key if defined?(@serializer_cache_key)
        @serializer_cache_key = [serializer.name, Digest::SHA256.hexdigest(serializer._attributes.keys.to_s)[0..12]]
      end

      def cache_key(object, _)
        [object.cache_key, *self.serializer_cache_key, 'serializable-hash']
      end
    end
  end
end