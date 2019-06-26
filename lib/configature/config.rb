class Configature::Config
  def initialize(path, format: :yaml, symbolize: true)
    if (File.exist?(path))
      case (format)
      when :yaml
        YAML.read(File.open(path))
      else
        raise "Unknown config file format #{format.inspect}"
      end
    end
  end
end
