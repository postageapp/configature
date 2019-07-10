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

  it 'allows declaring an environment layer with associated environment variable' do
    namespace = Configature::Namespace.new

    namespace.env :RAILS_ENV
  end
end
