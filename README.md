# Vaml

Vaml is Vault with YAML. It helps you manage your app's secrets from your yml files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vaml

## Usage

### Configuration
```
Vaml.configure do |v|
  v.host = "http://127.0.0.1:8200"
  v.token = ENV['VAULT_TOKEN']
end
```

or

`Vaml.configure(host: 'xxx', token: 'xxx')`


## Adding secrets
The gem provides a rake task that you can use to add secrets. As a developer, if you want to add a new secret:

* Use the following syntax in you YML. It is not necessary to follow the syntax, but it is highly recommended.
  `access_id: vault:/secret/data/staging/aws/access_id`

* Then, add your secret with `rake vaml:add_secret`. You will need to set an `ENV['VAULT_TOKEN']` to run this command.

`VAULT_TOKEN=my_token rake vaml:add_secret /secrets/data/staging/aws/access_id AXXSAWEDFSF`

* After you configure vault, you can also add secrets from the rails console using the same token.

  ```
  Vaml.write(key, value)
  ```

If you have been given proper access rights, you will be able to successfully write the secret.

### Limitations

* Gem supports only KV version 2 and all keys must include the `data` keyword.
Example: `/secret/data/staging/aws/access_id` will show on vault as `/secret/staging/aws/access_id`
The `data` keyword is required to work with Vault API for KV version 2.

### YAML Integration

Given, you have an input yml that looks like:
```
development:
  aws:
    access_id: 'XXX'
staging:
  aws:
    access_id: vault:/secret/data/staging/aws/access_id
production:
  aws:
    access_id: vault:/secret/data/production/aws/access_id
```

and you write these secrets with:
```
VAULT_TOKEN=my_token rake vaml:add_secret /secret/data/staging/aws/access_id ABC
VAULT_TOKEN=my_token rake vaml:add_secret /secret/data/production/aws/access_id DEF
```

When you access these secrets from vault,

`Vaml.from_yaml(File.read('input_yml.yml'))`

Vaml gives you back a ruby hash that looks like:

```
{
  "development" => {"aws"=>{"access_id"=>"XXX"}},
  "staging" => {"aws"=>{"access_id"=>"ABC"}},
  "production" => {"aws"=>{"access_id"=>"ABC"}}
}
```
Note that this does not actually write back to the file, and it is upto you to use this result as you want.
One strategy is to store these into the Rails configuration object when Rails initializes, so you will have it available to your process, but you won't need to write any secret anywhere. Bye bye to leaky ENV variables!


## Using Vault

This gem also contains a `docker/` directory with vault and consul setup for you.
To start vault on your local system with consul as the backend, clone the repo and run

`cd docker`
`docker-compose up`

or you can follow the official Vault documentation and install vault

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dgtm/vaml.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
