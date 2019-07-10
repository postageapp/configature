require 'date'

class Configature::Config
  # == Constants ============================================================
  
  # == Properties ===========================================================
  
  # == Class Methods ========================================================

  def self.namespace(name)
    @namespaces ||= { }
    @namespaces[name] = Namespace.new(name).tap { |v| yield(v) }
  end
  
  # == Instance Methods =====================================================

  def initialize
    
  end

  def method_missing(name)
    __fetch_parameter(name)
  end

protected
  def __fetch_parameter(name)
    nil
  end
end

require_relative './config/namespace'
