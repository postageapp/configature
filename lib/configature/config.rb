require 'date'

require_relative './data'
require_relative './support'

require_relative './namespace'

class Configature::Config < Configature::Data
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Class Methods ========================================================

  def self.namespace(name, env_suffix: '', extends: nil, &block)
    self.namespaces[name] = Configature::Namespace.new(name, env_suffix: env_suffix, extends: extends && self.namespaces[extends]).tap do |n|
      case (block&.arity)
      when nil
        nil
      when 1
        block[n]
      else
        n.instance_eval(&block)
      end
    end
  end

  def self.namespaces
    @namespaces ||= { }
  end
  
  # == Instance Methods =====================================================

  def initialize
    super(
      self.class.namespaces.transform_values do |namespace|
        Configature::Support.convert_hashes(Configature::Data, namespace.__instantiate)
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
