require 'date'

require_relative './data'
require_relative './support'

require_relative './namespace'

class Configature::Config < Configature::Data
  # == Constants ============================================================

  # == Properties ===========================================================

  # == Class Methods ========================================================

  def self.config_dir
    @config_dir ||= defined?(Rails) && Rails.root.join('config/')
  end

  def self.config_dir=(dir)
    @config_dir = dir
  end

  def self.namespace(name, file: nil, env_suffix: '', extends: nil, &block)
    extends &&= self.namespaces[extends]

    namespace = self.namespaces[name] = Configature::Namespace.new(name, env_suffix: env_suffix, extends: extends).tap do |n|
      case (block&.arity)
      when nil
        nil
      when 1
        block[n]
      else
        n.instance_eval(&block)
      end
    end

    file = (file || extends&.config_name || name).to_s

    if (file and !file.include?('.'))
      file += '.yml'
    end

    unless (self.respond_to?(name))
      iv = :"@#{name}"

      singleton_class.send(:define_method, name) do
        instance_variable_get(iv) or instance_variable_set(iv, namespace.__instantiate(
          source: Configature::Support.yaml_if_exist(File.expand_path(file, self.config_dir))
        ))
      end
    end
  end

  def self.namespaces
    @namespaces ||= { }
  end

  # == Instance Methods =====================================================

  def initialize(config_dir: nil, path: nil, env: ENV, data: nil)
    super(
      self.class.namespaces.map do |name, namespace|
        config = data || begin
          path ||= File.expand_path('%s.yml' % namespace.config_name, config_dir || self.class.config_dir)

          Configature::Support.yaml_if_exist(path)
        end

        [
          name,
          Configature::Support.convert_hashes(
            Configature::Data,
            namespace.__instantiate(source: config, env: env)
          )
        ]
      end.to_h
    )
  end

  def to_h
    super.map do |k, v|
      [
        k,
        case (v)
        when Array
          v.map do |e|
            e.respond_to?(:to_h) ? e.to_h : e
          end
        else
          v.respond_to?(:to_h) ? v.to_h : v
        end
      ]
    end.to_h
  end
end
