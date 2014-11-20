module Autobots
  module Helpers
    module ActiveRecordPreloading

      def transform(objects)
        ActiveRecord::Associations::Preloader.new.preload(objects, preloads)
        objects
      end

      def preloads
        []
      end
    end
  end
end