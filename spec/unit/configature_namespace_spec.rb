RSpec.describe Configature::Namespace do
  it 'has minimal defaults' do
    namespace = Configature::Namespace.new

    expect(namespace.__instantiate).to eq({ })
    expect(namespace.name).to be_nil
  end

  it 'allows defining arbitrary parameters' do
    namespace = Configature::Namespace.new

    namespace.example default: 'value'

    expect(namespace[:example][:env]).to eq('EXAMPLE')

    expect(namespace.__instantiate).to eq(example: 'value')
  end

  it 'allows defining arbitrary parameters with proper prefixing' do
    namespace = Configature::Namespace.new(:namespace)

    namespace.example default: 'value'

    expect(namespace[:example][:env]).to eq('NAMESPACE_EXAMPLE')

    expect(namespace.__instantiate).to eq(example: 'value')
  end

  it 'allows declaring an environment layer with associated environment variable' do
    namespace = Configature::Namespace.new

    namespace.env :RAILS_ENV
  end

  it 'allows declaring namespaces within a namespace' do
    root = Configature::Namespace.new(:root)

    root.namespace(:inner) do
      value default: 'default'
    end

    expect(root[:inner]).to be
    expect(root[:inner][:value]).to be
    expect(root[:inner][:value][:env]).to eq('ROOT_INNER_VALUE')

    data = root.__instantiate(env: { 'ROOT_INNER_VALUE' => 'env_value' })

    expect(data).to eq(inner: { value: 'env_value' })
  end

  it 'allows declaring namespaces within a namespace with custom ENV names' do
    root = Configature::Namespace.new(:root)

    root.namespace(:inner) do
      custom env: 'INNER_VALUE'
      no_env env: false 
    end

    expect(root[:inner][:custom][:env]).to eq('INNER_VALUE')
    expect(root[:inner][:no_env][:env]).to eq(false)

    data = root.__instantiate(env: { 'INNER_VALUE' => 'env_value' })

    expect(data).to eq(inner: { custom: 'env_value', no_env: nil })
  end
  
  it('imports settings for a defined environment') do
    namespace = Configature::Namespace.new
    namespace.environment_name 
    namespace.namespace :nested do
      content as: :integer, default: 0
    end

    namespace.env 'IMPORT_EXAMPLE_ENV'

    ENV['IMPORT_EXAMPLE_ENV'] = 'development'

    source = YAML.safe_load(
      File.open(File.expand_path('../examples/with_environment.yml', __dir__))
    )

    data = namespace.__instantiate(source: source)

    expect(data).to eq(
      environment_name: 'development',
      nested: {
        content: 29
      }
    )
  end

  it('imports settings from a YAML file') do
    namespace = Configature::Namespace.new
    namespace.test 
    namespace.namespace :nested do
      content as: :integer, default: 0
    end

    source = YAML.safe_load(
      File.open(File.expand_path('../examples/without_environment.yml', __dir__))
    )

    data = namespace.__instantiate(source: source)

    expect(data).to eq(
      test: 'value',
      nested: {
        content: 22
      }
    )
  end

  context 'supports rewriting certain parameters' do
    it 'using a Hash look-up table' do
      namespace = Configature::Namespace.new
      namespace.remapped remap: { 'one' => '1', 'two' => '2' }

      data = namespace.__instantiate(source: { remapped: 'one' })

      expect(data).to eq(remapped: '1')
    end

    it 'using a Proc' do
      namespace = Configature::Namespace.new
      namespace.remapped remap: -> (v) { v.to_s }

      data = namespace.__instantiate(source: { remapped: 1 })

      expect(data).to eq(remapped: '1')
    end
  end

  context 'can declare defaults' do
    it 'as inline values' do
      default = 'example'

      namespace = Configature::Namespace.new
      namespace.with_default default: default

      data = namespace.__instantiate

      expect(data).to eq(with_default: 'example')
    end

    it 'using a proc' do
      default = 'example'

      namespace = Configature::Namespace.new
      namespace.with_default default: -> { default }

      data = namespace.__instantiate

      expect(data).to eq(with_default: 'example')
    end
  end
end
