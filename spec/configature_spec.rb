RSpec.describe Configature do
  it "has a version number" do
    expect(Configature::VERSION).not_to be nil
  end

  context 'can properly enumerate parent directories' do
    it 'on a POSIX system' do
      path = '/a/very/long/path/to/something'

      dirs = Configature.dir_plus_parents(path).to_a

      expect(dirs).to eq(%w[
        /a/very/long/path/to/something
        /a/very/long/path/to
        /a/very/long/path
        /a/very/long
        /a/very
        /a
        /
      ])
    end
  end
end
