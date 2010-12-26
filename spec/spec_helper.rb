$:.unshift(File.expand_path("../../lib", __FILE__))

require 'queue-patch'

def fixture(name)
  File.expand_path("../fixture-data/#{name}", __FILE__)
end