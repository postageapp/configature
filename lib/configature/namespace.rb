require 'date'

require_relative './support'

class Configature::Namespace
  # == Constants ============================================================

  BOOLEAN_EQUIVALENT = begin
    h = {
      true => %w[ on yes 1 ],
      false => %w[ off no 0 ]
    }.flat_map do |k, a|
      a.map do |v|
        [ v, k ]
      end
    end.to_h

    -> (v) do
      b = h[v]

      b.nil? ? !!v : b
    end
  end

  RECAST_AS = {
    [ :array, Array ] => -> (v) { v.is_a?(Array) ? v : [ v ] },
    [ :string, String ] => :to_s.to_proc,
    [ :integer, Integer ] => :to_i.to_proc,
    [ :float, Float ] => :to_f.to_proc,
    [ :boolean ] => -> (v) { BOOLEAN_EQUIVALENT[v] },
    [ :date, Date ] => -> (v) { Date.parse(v) },
    [ :datetime, DateTime ] => -> (v) { DateTime.parse(v) },
    [ :time, Time ] => -> (v) { v.match?(/\A\d+\z/) ? Time.at(v.to_i) : Time.parse(v) }
  }.flat_map do |a, v|
    a.map do |k|
      [ k, v ]
    end
  end.to_h.freeze

  # == Properties ===========================================================

  attr_reader :name
  attr_reader :config_name
  attr_reader :env_name_prefix
  attr_reader :namespaces
  attr_reader :parameters

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize(name = nil, env_name_prefix: '', env_suffix: '', extends: nil)
    @name = name&.to_sym
    @extends = extends
    @env = extends&.instance_variable_get(:@env)
    @env_default = extends&.instance_variable_get(:@env_default)
    @namespaces = extends&.namespaces&.dup || { }
    @parameters = extends&.parameters&.dup || { }
    @env_suffix = env_suffix
    @env_name_prefix = name ? Configature::Support.extend_env_prefix(env_name_prefix, name) : ''

    @config_name = extends&.config_name || name

    yield(self) if (block_given?)
  end

  def namespace(name, env_suffix: '', extends: nil, &block)
    name = name.to_sym

    @namespaces[name] = self.class.new(
      name,
      env_suffix: env_suffix,
      extends: extends && self.namespaces[extends],
      env_name_prefix: @env_name_prefix
    ).tap do |n|
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

  def parameter(parameter_name, default: nil, as: nil, name: nil, env: nil, remap: nil)
    name ||= parameter_name
    as ||= default.is_a?(Array) ? :array : :string

    case (as)
    when Class, Symbol
      as = RECAST_AS[as]
    end

    @parameters[name] = {
      name: name,
      default: default.is_a?(Proc) ? default : -> { default },
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

  def __instantiate(source: nil, env: ENV)
    if (@env and source)
      env_key = @env.map { |e| env[e] }.first || @env_default

      if (@env_suffix)
        env_key += @env_suffix
      end

      source = source[env_key] || source[env_key.to_sym]
    end

    self.__instantiate_branch(source: source, env: env)
  end

  def __instantiate_branch(source: nil, env: nil)
    Configature::Data.new(
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

        if (!value.nil? and as = param[:as])
          value = as[value]
        end

        [ param[:name], value.nil? ? param[:default].call : value ]
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
    )
  end
end
