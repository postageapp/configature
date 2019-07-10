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

RSpec.describe Configature::Config do
  context 'can create' do
    it 'complex configurations with multiple namespaces' do
      map = ConfigMapExample.new

      expect(map.rabbitmq.host).to eq('localhost')
    end
  end
end
