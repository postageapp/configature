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
end
