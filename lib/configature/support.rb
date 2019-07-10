module Configature::Support
  # == Module and Mixin Methods =============================================

  def extend_env_prefix(base, with)
    return unless (base)

    case (base)
    when ''
      with
    else
      base + '_' + with
    end
  end

  def encapsulate_hashes(obj)
  end

  extend self
end
