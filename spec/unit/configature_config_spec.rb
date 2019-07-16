class SimpleExample < Configature::Config
  namespace :main do
    example default: 'value'
  end
end

class ConfigMapExample < Configature::Config
  namespace :rabbitmq do |rmq|
    rmq.host default: 'localhost'
    rmq.port as: :integer, default: 5672
    rmq.username default: 'guest'
    rmq.password default: 'guest'
  end

  namespace :database do |database|
  end

  namespace :nested do |outer|
    outer.namespace :inner do |inner|
      inner.param default: 'inner_param'
    end
  end
end

class ConfigWithNamespaceParameter < Configature::Config
  namespace :main do |main|
    main.property name: :namespace
  end
end

class ConfigWithNamespaceEnvVariants < Configature::Config
  namespace :database do |db|
    db.env 'RAILS_ENV', default: 'development'

    db.database default: 'appname'
    db.host default: 'localhost'
    db.port as: :integer, default: 3306
    db.username default: 'guest'
    db.password default: 'guest'
  end

  namespace :database_secondary, env_suffix: '_secondary', extends: :database do |db|
    db.database default: 'appname_secondary'
  end
end

RSpec.describe Configature::Config do
  context 'can have' do
    it 'simple configurations with one namespace' do
      simple = SimpleExample.new

      expect(simple.main.class).to eq(Configature::Data)
      expect(simple.main.example).to eq('value')

      expect(simple.to_h).to eq(main: { example: 'value' })

      expect(SimpleExample.main).to eq(example: 'value')
    end

    it 'complex configurations with multiple namespaces' do
      map = ConfigMapExample.new

      expect(map.rabbitmq).to be
      expect(map.rabbitmq.host).to eq('localhost')
    end

    it 'inheritance from other namespaces' do
      map = ConfigWithNamespaceEnvVariants.new

      expect(map.to_h).to eq(
        database: {
          database: 'appname',
          host: 'localhost',
          port: 3306,
          username: 'guest',
          password: 'guest'
        },
        database_secondary: {
          database: 'appname_secondary',
          host: 'localhost',
          port: 3306,
          username: 'guest',
          password: 'guest'
        }
      )
    end
  end
end
