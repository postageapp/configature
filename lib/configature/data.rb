require 'ostruct'

class Configature::Data < OpenStruct
  # == Class Methods ========================================================

  def self.hashify(data)
    case (data)
    when Configature::Data
      data.to_h
    when Array
      data.map do |v|
        hashify(v)
      end
    else
      data
    end
  end

  # == Instance Methods =====================================================

  def to_h
    super.map do |k, v|
      [ k, self.class.hashify(v) ]
    end.to_h
  end
end
