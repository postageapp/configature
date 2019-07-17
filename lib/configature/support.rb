module Configature::Support
  # == Module and Mixin Methods =============================================

  def extend_env_prefix(base, with)
    return base unless (base)
    return with unless (with)

    case (base)
    when ''
      with.to_s.upcase
    else
      base.upcase + '_' + with.to_s.upcase
    end
  end

  def convert_hashes(to_class, obj)
    case (obj)
    when Hash, OpenStruct, Configature::Data
      to_class.new(
        obj.to_h.map do |k, v|
          [ k, convert_hashes(to_class, v) ]
        end.to_h
      )
    when Array
      obj.map do |v|
        convert_hashes(to_class, v)
      end
    else
      obj
    end
  end

  extend self
end
