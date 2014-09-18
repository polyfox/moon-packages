module Visibility
  attr_writer :visible

  def visible
    @visible = true if @visible.nil?
    @visible
  end

  def hide
    @visible = false
    self
  end

  def show
    @visible = true
    self
  end
end
