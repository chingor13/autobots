module Autobots
  class ActiveRecordAssembler < Assembler
    include Helpers::ActiveRecordPreloading
  end
end