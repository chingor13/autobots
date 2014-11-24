module Autobots
  module Helpers
    module ActiveRecordPreloading
      extend ActiveSupport::Concern

      included do
        class_attribute :preloads
        self.preloads = []
      end

      def transform(objects)
        ActiveRecord::Associations::Preloader.new(objects, preloads).run
        objects
      rescue ArgumentError
        ActiveRecord::Associations::Preloader.new.preload(objects, preloads)
        objects
      end

    end
  end
end