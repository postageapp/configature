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
  attr_reader :env_name_prefix
  attr_reader :namespaces
  attr_reader :parameters
  
  # == Class Methods ========================================================
  
  # == Instance Methods =====================================================

  def initialize(name = nil, env_name_prefix: '', env_suffix: '', extends: nil)
    @name = name&.to_sym
    @extends = extends
    @namespaces = extends ? extends.namespaces.dup : { }
    @parameters = extends ? extends.parameters.dup : { }
    @env_suffix = env_suffix
    @env_name_prefix = name ? Configature::Support.extend_env_prefix(env_name_prefix, name) : ''

    yield(self) if (block_given?)
  end

  def namespace(name, &block)
    name = name.to_sym

    @namespaces[name] = self.class.new(name, env_name_prefix: @env_name_prefix).tap do |n|
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

  def env(*names, default: 'development')
    @env = names.map(&:to_s).freeze
    @env_default = default
  end

  def parameter(parameter_name, default: nil, as: :string, name: nil, env: nil, remap: nil)
    name ||= parameter_name

    @parameters[name] = {
      name: name,
      default: default,
      as: as,
      remap: remap,
      env:
        case (env)
        when false
          false
        when nil
          Configature::Support.extend_env_prefix(@env_name_prefix, name)
        else
          env
        end
    }
  end

  def [](name)
    @parameters[name] or @namespaces[name]
  end

  def method_missing(name, **options)
    parameter(name, **options)
  end

  def __instantiate(source: nil, env: nil)
    if (@env and source)
      env_key = @env.map { |e| ENV[e] }.first || @env_default

      source = source[env_key] || source[env_key.to_sym]
    end

    self.__instantiate_branch(source: source, env: env)
  end

  def __instantiate_branch(source: nil, env: nil)
    @parameters.values.map do |param|
      name = param[:name]
      name_s = name.to_s
      name_sym = name_s.to_sym

      value = (param[:env] && env && env[param[:env]]) ||
        source && (source[name_s] || source[name_sym])
        

      case (remap = param[:remap])
      when Hash, Proc
        value = remap[value] || value
      end

      [ param[:name], value.nil? ? param[:default] : value ]
    end.to_h.merge(
      @namespaces.map do |name, namespace|
        [
          name,
          namespace.__instantiate_branch(
            source: source && (source[name] || source[name.to_s]),
            env: env
          )
        ]
      end.to_h
    )
  end
end
