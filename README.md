# Configature

Configuature is a tool to assist in creating config files from templates.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configature'
```

And then execute:

```shell
bundle
bundle binstubs configature
```

Or install it yourself as:

```shell
gem install configature
```

## Usage

Configuature expects a `config/` directory that contains one or more files
with the file extension `.example`, as in `database.yml.example`. Any files
of that form found will be copied to their corresponding name minus the
`.example` extension *if* no such file exists.

This is done with the command:

```shell
bin/config
```

Where files already exist these are not touched, but are noted in the output
as being "present".

The opposite step is to remove these files:

```shell
bin/config clean
```

<blockquote>
Keep in mind this may remove important credentials so this should be done
carefully if and only if necessary.
</blockquote>

### Definining Configuration

Most applications should have a configuration definition like this where
one or more *namespace* is defined where configuration information is stored:

```ruby
class MyConfig < Configature::Config
  namespace :example do
    argument default: 'value'
  end
end
```

In this case a single namespace is defined. When instantiated the configuration
values can be read:

```ruby
config = MyConfig.new
config.example.argument
# => 'value'
```

This can also be accessed through a factory method that provides convenient
defaults:

```ruby
Config.example.argument
# => 'value'
```

In most cases this can be adequate. The `MyConfig.new` approach allows
specifying which config file to load and which environment to read from,
something that may be important in some situations.

The default is to load from `ENV`, the main environment, and `config/`
relative to `Rails.root` if `Rails` is defined.

This value can be overridden with the environment variable `EXAMPLE_ARGUMENT`
or in a config file `config/example.yml` under the `argument:` key.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and
then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/postageapp/configature).
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Configature project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/tadman/configature/blob/master/CODE_OF_CONDUCT.md).
