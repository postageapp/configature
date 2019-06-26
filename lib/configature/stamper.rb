class Configature::Stamper
  def initialize(dir)
    @dir = dir
  end

  def examples
    map = Dir.glob(File.expand_path('*.example', @dir)).map do |source|
      [ source, source.delete_suffix('.example') ]
    end.to_h

    if (block_given?)
      map.each do |k,v|
        yield(k, v)
      end
    end

    map
  end

  def clean!
    self.examples.each do |_source, target|
      if (File.exist?(target))
        File.unlink(target)

        yield(target) if (block_given?)
      end
    end
  end

  def apply!(force: false)
    self.examples.each do |source, target|
      if (!force and File.exist?(target))
        yield(
          source,
          target,
          created: false,
          existing: true,
          config_required: !!File.read(target).match(/__[A-Z\-\_]+__/)
        ) if (block_given?)
      else
        FileUtils.copy(source, target)
    
        yield(
          source,
          target,
          created: true,
          existing: false,
          config_required: !!File.read(target).match(/__[A-Z\-\_]+__/)
        ) if (block_given?)
      end
    end
  end
end
