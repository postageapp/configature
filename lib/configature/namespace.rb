require 'date'

require_relative './support'

class Configature::Namespace
  # == Constants ============================================================

  AS_BOOLEAN = Hash.new { |h,k| h[k] = !!k }.merge(
    'on' => true,
    'off' => false,
    'yes' => true,
    'no' => false,
    '1' => true,
    '0' => false
  ).freeze

  RECAST = {
    string: -> (v) { v.to_s },
    integer: -> (v) { v.to_i },
    float: -> (v) { v.to_f },
    boolean: -> (v) { AS_BOOLEAN[v] },
    date: -> (v) { Date.parse(v) },
    datetime: -> (v) { DateTime.parse(v) },
    time: -> (v) { v.match?(/\A\d+\z/) ? Time.at(v.to_i) : Time.parse(v) }
  }.freeze
  
  # == Properties ===========================================================

  attr_reader :name
  attr_reader :parameters
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(name = nil, env_prefix: nil)
    @name = name&.to_sym
    @namespaces = { }
    @parameters = { }
    @env_prefix = env_prefix === false ? nil : ''

    yield(self) if (block_given?)
  end

  def namespace(name)
    @namespaces[name] = self.class.new(name).tap { |n| yield(n) }
  end

  def env(*names)
    @env = names.map(&:to_s).freeze
  end

  def parameter(parameter_name, default: nil, as: :string, name: nil, env: nil)
    name ||= parameter_name

    @parameters[name] = {
      name: name,
      default: default,
      as: as,
      env:
        case (env)
        when false
          false
        when nil
          Configature::Support.extend_env_prefix(@env_prefix, name)
        else
          env
        end
    }
  end

  def [](name)
    @parameters[name]
  end

  def method_missing(name, **options)
    parameter(name, **options)
  end

  def __instantiate(data: nil, env_prefix: nil)
    @parameters.values.map do |param|
      name = param[:name]
      name_s = name.to_s
      name_sym = name_s.to_sym

      [ param[:name], data && (data[name_s] || data[name_sym]) || param[:default] ]
    end.to_h.merge(
      @namespaces.map do |name, namespace|
        [
          name,
          namespace.__instantiate(
            data: data && data[namespace],
            env_prefix: Configature::Support.extend_env_prefix(
              env_prefix,
              namespace.upcase
            )
          )
        ]
      end.to_h
    )
  end
end
