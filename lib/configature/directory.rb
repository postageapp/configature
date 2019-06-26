module Configature::Directory
  def self.parents(dir)
    Enumerator.new do |y|
      y << dir

      loop do
        last, dir = dir, File.expand_path('../', dir)

        break if (last == dir)

        y << dir
      end
    end
  end

  def self.find(name)
    parents(Dir.pwd).lazy.map do |dir|
      File.expand_path(name, dir)
    end.find do |dir|
      File.directory?(dir)
    end
  end
end
