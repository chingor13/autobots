# Autobots [![Build Status](https://travis-ci.org/chingor13/autobots.png)](https://travis-ci.org/chingor13/autobots)

Loading and serializing models in bulk with caching.

Separate the loading/serialization of resources from their protocol (http/json, avro, xml).

We want to improve api response time by loading the minimum amount of data needed to check cache keys. If we miss, we want to optimally load our data, serialize it, cache it and then return it.

## Problem

Say we have a simple api action:

	def index
	  # find our records
	  projects = Project.includes(issues: :comments).first(10)
	  render json: projects, each_serializer: ProjectSerializer
	end

How do we cache this?

    class ProjectSerializer < ActiveModel::Serializer
      cached
    end

    def index
      projects = Project.includes(issues: :comments).first(10)
      render json: projects, each_serializer: ProjectSerializer
    end

There are 2 problems with this approach:

1. We're making 3 sql calls every time regardless of what keys are required for checking the cache
2. We're making 10 cache fetch requests

We can fix this by fetching the bare minimum amount of data needed to check the cache, checking the cache in bulk, then loading the data needed in an optimized fashion for cache misses only.

This gem's goal is to abstract all that logic into a testable, declarative model that can improve your api's response time. We also want to return serializable data so that we decouple the definition of a resource from its protocols (not locked to json or xml)

## Usage

An `Autobots::Assembler` is the core of the `autobots` gem. The input for an autobot is that you provide an array of objects needed to build your cache keys. The output is an array of serializable data that corresponds to the input set (retaining order).

![flow](docs/flow.png)

### Lifecycle of an Autobot

When trying to render a resource for an API, we have 3 parts:

1. Fetching data
2. Figuring out the data to return
3. Format it for the protocol

Each of these methods corresponds to a single lifecycle method of an autobot:

1. `assemble`
2. `transform`
3. `roll_out`


#### Fetching data (assemble)

An `assembler` can optionally load whatever data is required to build it's cache keys. The assembler's job is to fetch all data needed for serialization as optimally as possible. The identifiers should be the minimum amount of data needed to fetch data and determine caching.

	class ProjectAssembler < Autobots::Assembler
	
	  # assembles the base objects needed for cache key generation
	  def assemble(identifiers)
	    Project.where(id: identifiers).to_a
	  end
	
	end

	project_ids = [1,2,3]
	assembler = ProjectAssembler.new(project_ids)
	
	# returns preloaded objects for serialization
	objects = assembler.objects

#### Figuring out the data to return (transform)

The transform lifecycle event is called with every object that needs refreshing. It allows us to to optimize our loading of nested resources by using bulk loading. If caching is enabled, we only need to run this on resources that missed the cache. We may not even need to run it at all!

An example of this would be using `ActiveRecord::Associations::Preloader` to fetch included records if necessary:

	class ProjectAssembler < Autobots::Assembler
	  def transform(resources)
	  	ActiveRecord::Associations::Preloader.new().preload(resources, {issues: :comments})
	  end
	end

Since this is a fairly common pattern, I created the `Autobots::ActiveRecordAssembler` that has this default behavior:

	class ProjectAssembler < Autobots::ActiveRecordAssembler
	  self.preloads = {issues: :comments}
	end

The strength of this model lies in minimizing data fetch requests when building our data to serialize. We do this by delaying the loading of nested models and only load them if we have to.

If a resources's cache is up to date, we shouldn't have to fetch it's dependencies from the database. However, if we have a cache miss, we want to optimally load the data needed.

#### Formatting the response

We use the `active_model_serializers` gem to accomplish serialization. An assembler declares the type of serializer used to specify the data returned


	class ProjectAssembler < Autobots::Assembler
	  self.serializer = ProjectSerializer # an ActiveModel::Serializer
	end
	
	# returns an array of data for serialization
	data = assembler.data

`autobots` gem only handles the loading and representation of the data.

### Caching

We can get large performance boosts by caching our serializable data. Caching is straight forward:

	# some sort of ActiveSupport::CacheStore
	cache = Rails.cache
	assembler = ProjectAssembler.new(project_ids, cache: cache)

The cache store must implement `read_multi` as we use [`bulk_cache_fetcher` gem](https://github.com/justinweiss/bulk_cache_fetcher/)

By default, we use each resource's `cache_key` implementation. You can provide your own cache key generator by passing in a cache_key proc:

	assembler = ProjectAssembler.new(project_ids, {
	  cache: cache,
	  cache_key: -> (obj, assembler) {
	    "#{obj.cache_key}-foo"
	  }
	})


## Contributing

1. Fork it ( https://github.com/chingor13/autobots/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
