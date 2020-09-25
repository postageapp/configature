require 'ostruct'

RSpec.describe Configature::Support do
  include Configature::Support

  context 'extend_env_prefix' do
    it 'will not extend nil' do
      expect(extend_env_prefix(nil, 'level_1')).to eq(nil)
    end

    it 'will not extend false' do
      expect(extend_env_prefix(false, 'level_1')).to eq(false)
    end

    it 'will extend an empty string' do
      expect(extend_env_prefix('', 'level_1')).to eq('LEVEL_1')
    end

    it 'will append to an existing string' do
      expect(extend_env_prefix('level_1', :level_2)).to eq('LEVEL_1_LEVEL_2')
    end

    it 'will return nil when given nil' do
      expect(extend_env_prefix('TEST', nil)).to eq(nil)
    end

    it 'will return false when given false' do
      expect(extend_env_prefix('TEST', false)).to eq(false)
    end
  end

  context 'convert_hashes' do
    it 'will rewrap simple hash-type values into OpenStruct' do
      encapsulated = convert_hashes(OpenStruct, example: true)

      expect(encapsulated.class).to be(OpenStruct)

      expect(encapsulated).to eq(
        OpenStruct.new(example: true)
      )

      expect(encapsulated.example).to eq(true)
    end

    it 'will rewrap nested hash-type values into OpenStruct' do
      encapsulated = convert_hashes(
        OpenStruct,
        example: {
          nested: {
            value: 'inner'
          }
        }
      )

      expect(encapsulated.class).to be(OpenStruct)

      expect(encapsulated).to eq(
        OpenStruct.new(example: OpenStruct.new(nested: OpenStruct.new(value: 'inner')))
      )

      expect(encapsulated.example.nested.value).to eq('inner')
    end

    it 'will rewrap nested arrays of hash-type values into OpenStruct' do
      encapsulated = convert_hashes(
        OpenStruct,
        list: [
          { a: 1 },
          { b: 2 },
          { c: 3 }
        ]
      )

      expect(encapsulated).to eq(
        OpenStruct.new(list: [
          OpenStruct.new(a: 1),
          OpenStruct.new(b: 2),
          OpenStruct.new(c: 3)
        ])
      )

      expect(encapsulated.list[1].b).to be(2)
    end

    it 'will default an empty config to an empty Hash' do
      empty_yml = File.expand_path('../examples/without_array.yml', __dir__)

      expect(yaml_if_exist(empty_yml)).to eq({ })
    end

    it 'leaves non-hash values as-is' do
      [
        'string',
        1,
        1.0,
        false,
        true,
        nil
      ].each do |value|
        expect(convert_hashes(OpenStruct, value)).to eq(value)
      end
    end
  end
end
