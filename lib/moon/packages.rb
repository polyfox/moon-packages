MOON_PACKAGE_ROOT = File.join(File.dirname(__FILE__), 'packages')

module Moon
  def self.bootstrap_packagedir
    $LOAD_PATH << MOON_PACKAGE_ROOT unless $LOAD_PATH.include?(MOON_PACKAGE_ROOT)
  end

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

Moon.bootstrap_packagedir
