MOON_MODULE_ROOT = File.join(File.dirname(__FILE__), 'modules')

##
# :nodoc:
module Kernel
  def load_moon_module(basename)
    require File.join(MOON_MODULE_ROOT, basename)
  end
end
