require 'yaml'

module Configature
  VERSION = File.readlines(
    File.expand_path('../VERSION', __dir__)
  ).first.chomp.freeze

  class Error < StandardError; end

  def self.version
    VERSION
  end
end

require_relative './configature/config'
require_relative './configature/directory'
require_relative './configature/stamper'
