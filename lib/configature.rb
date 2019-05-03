module Configature
  VERSION = File.readlines(File.expand_path('../VERSION', __dir__)).first.chomp.freeze

  class Error < StandardError; end
  # Your code goes here...

  def self.version
    VERSION
  end

  def self.dir_plus_parents(dir)
    Enumerator.new do |y|
      y << dir

      loop do
        last, dir = dir, File.expand_path('../', dir)

        break if (last == dir)

        y << dir
      end
    end
  end

  def self.config_dir
    dir_plus_parents(Dir.pwd).lazy.map do |dir|
      File.expand_path('config', dir)
    end.find do |dir|
      File.directory?(dir)
    end
  end

  def self.configable_examples(dir)
    map = Dir.glob(File.expand_path('*.example', dir)).map do |source|
      [ source, source.delete_suffix('.example') ]
    end.to_h

    if (block_given?)
      map.each do |k,v|
        yield(k, v)
      end
    end

    map
  end
end
