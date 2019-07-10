RSpec.describe Configature::Directory do
  context 'can properly enumerate parent directories' do
    it 'on a POSIX system' do
      path = '/a/very/long/path/to/something'

      dirs = Configature::Directory.parents(path).to_a

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
