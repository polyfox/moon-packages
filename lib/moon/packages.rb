MOON_PACKAGE_ROOT = File.join(File.dirname(__FILE__), 'packages')

module Moon
  def self.require_package(basename)
    require File.join(MOON_PACKAGE_ROOT, basename)
  end
end
##
# :nodoc:
module Kernel
  def require_moon_package(basename)
    require_package basename
  end

  def load_moon_package(basename)
    require_package basename
  end
end
