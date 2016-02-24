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

  def test_can_force_cache_clear
    cache = ActiveSupport::Cache::MemoryStore.new
    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects, cache: cache)

    # warming cache
    expected_data =  nil
    assert_queries 3 do
      expected_data = assembler.data
    end

    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects, cache: cache, force_reload: true)
    data = nil
    assert_queries 3 do
      data = assembler.data
    end

    assert_equal expected_data, data
  end

  def test_cache_key_contains_associations
    cache = ActiveSupport::Cache::MemoryStore.new
    projects = Project.all
    assembler = ProjectPreloadIncludedAssembler.new(projects, cache: cache)
    cache_key_with_associations = assembler.send(:serializer_cache_key)

    saved_associations = assembler.serializer._associations
    assembler.serializer._associations = {}
    assembler.remove_instance_variable(:@serializer_cache_key)

    cache_key_without_associations = assembler.send(:serializer_cache_key)

    assembler.serializer._associations = saved_associations

    assert_not_equal cache_key_with_associations, cache_key_without_associations
  end

end