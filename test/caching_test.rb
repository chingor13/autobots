require 'test_helper'

class CachingTest < ActiveSupport::TestCase
  fixtures :all

  def test_can_cache
    cache = ActiveSupport::Cache::MemoryStore.new
    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects, cache: cache)

    # warming cache
    expected_data =  nil
    assert_queries 3 do
      expected_data = assembler.data
    end

    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects, cache: cache)
    data = nil
    assert_queries 1 do
      data = assembler.data
    end

    assert_equal expected_data, data
  end

end