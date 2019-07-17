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

  def self.namespace(name, env_suffix: '', extends: nil, &block)
    namespace = self.namespaces[name] = Configature::Namespace.new(name, env_suffix: env_suffix, extends: extends && self.namespaces[extends]).tap do |n|
      case (block&.arity)
      when nil
        nil
      when 1
        block[n]
      else
        n.instance_eval(&block)
      end
    end

    unless (self.respond_to?(name))
      iv = :"@#{name}"

      singleton_class.send(:define_method, name) do
        config_path = File.expand_path('%s.yml' % name, self.config_dir)

        config = File.exist?(config_path) ? YAML.safe_load(File.open(config_path)) : nil

        instance_variable_get(iv) or instance_variable_set(iv, namespace.__instantiate(source: config))
      end
    end
  end

  def self.namespaces
    @namespaces ||= { }
  end
  
  # == Instance Methods =====================================================

  def initialize(config_dir: nil, env: ENV)
    super(
      self.class.namespaces.map do |name, namespace|
        config_path = File.expand_path('%s.yml' % name, config_dir || self.class.config_dir)

        config = File.exist?(config_path) ? YAML.safe_load(File.open(config_path)) : nil

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
