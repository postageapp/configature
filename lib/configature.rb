module Configature
  VERSION = File.readlines(File.expand_path('../VERSION', __dir__)).first.chomp.freeze

  class Error < StandardError; end
  # Your code goes here...

  def version
    VERSION
  end
end
