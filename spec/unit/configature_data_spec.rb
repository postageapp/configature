RSpec.describe Configature::Data do
  context 'can be initialized with' do
    it 'defaults' do
      data = Configature::Data.new

      expect(data.test).to eq(nil)
      expect(data.to_h).to eq({ })
    end
    it 'a Hash' do
      data = Configature::Data.new(test: 'value')

      expect(data.test).to eq('value')
      expect(data.to_h).to eq(test: 'value')
    end
  end

  context 'can be converted to a regular Hash' do
    it 'at one level' do
      data = Configature::Data.new(test: 'value')

      expect(data.to_h).to eq(test: 'value')
    end

    it 'with nested Data structures' do
      data = Configature::Data.new(
        top: Configature::Data.new(
          level: 1
        ),
        array: [
          Configature::Data.new(index: 0),
          Configature::Data.new(index: 1),
          [
            Configature::Data.new(index: 2),
          ]
        ]
      )

      expect(data.to_h).to eq(
        top: {
          level: 1
        },
        array: [
          { index: 0 },
          { index: 1 },
          [
            { index: 2 }
          ]
        ]
      )
    end
  end
end
