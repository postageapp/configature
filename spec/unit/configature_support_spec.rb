RSpec.describe Configature::Support do
  include Configature::Support

  context 'extend_env_prefix' do
    it 'will not extend nil' do
      expect(extend_env_prefix(nil, 'level_1')).to eq(nil)
    end

    it 'will extend an empty string' do
      expect(extend_env_prefix('', 'level_1')).to eq('level_1')
    end

    it 'will append to an existing string' do
      expect(extend_env_prefix('level_1', 'level_2')).to eq('level_1_level_2')
    end
  end
end
