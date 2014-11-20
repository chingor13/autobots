module Autobots
  module Helpers
    module ActiveRecordPreloading

      def transform(objects)
        ActiveRecord::Associations::Preloader.new(objects, preloads).run
        objects
      rescue ArgumentError
        ActiveRecord::Associations::Preloader.new.preload(objects, preloads)
        objects
      end

      def preloads
        []
      end
    end
  end
end