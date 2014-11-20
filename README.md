# Autobots

Loading and serializing models in bulk with caching.

Separate the loading/serialization of resources from their protocol (http/json, avro, xml).

## Motivation

We want to improve api response time by loading the minimum amount of data needed to check cache keys. If we miss, we want to optimally load our data, serialize it, cache it and then return it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'autobots'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autobots

## Usage

When trying to render a resource for an API, we have 3 parts:

1. Fetching data
2. Figuring out the data to return
3. Format it for the protocol

### Fetching data

`autobots` uses `Autobots::Assembler` classes to fetch data from given identifiers.  The assembler's job is to fetch all data needed for serialization as optimally as possible. The identifiers should be the minimum amount of data needed to fetch data and determine caching.

```ruby

project_ids = [1,2,3]
assembler = ProjectAssembler.new(project_ids)

# returns preloaded objects for serialization
resources = assembler.resources

```

### Figuring out the data to return

We use the `active_model_serializers` gem to accomplish serialization. An assembler declares the type of serializer used to 

### Formatting the response

`autobots` gem only handles the loading and representation of the data.

### Caching

We can get large performance boosts by caching our serializable data. Caching is straight forward:

```ruby

# some sort of ActiveSupport::CacheStore
cache = Rails.cache
assembler = ProjectAssembler.new(project_ids, cache: cache)

```

The cache store must implement `read_multi` as we use [`bulk_cache_fetcher` gem](https://github.com/justinweiss/bulk_cache_fetcher/)

By default, we use each resource's `cache_key` implementation. You can provide your own cache key generator by passing in a cache_key proc:

```ruby

assembler = ProjectAssembler.new(project_ids, {
  cache: cache,
  cache_key: -> (obj, assembler) {
    "#{obj.cache_key}-foo"
  }
})

```

## Contributing

1. Fork it ( https://github.com/chingor13/autobots/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
