require 'date'

class Configature::Config
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Class Methods ========================================================

  def self.namespace(name)
    self.namespaces[name] = Namespace.new(name).tap { |v| yield(v) }
  end

  def self.namespaces
    @namespaces ||= { }
  end
  
  # == Instance Methods =====================================================

  def initialize(path: nil, env: true)
    @data = self.class.namespaces.map do |name, namespace|
      [ name, namespace.__instantiate ]
    end.to_h
  end

  def [](name)
    @data[name]
  end

  def method_missing(name, *args)
    send(:[], name)
  end

  def to_h
    @data.map do |k, v|
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

require_relative './config/namespace'
