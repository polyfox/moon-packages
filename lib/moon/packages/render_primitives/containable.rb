module Moon
  module RenderPrimitive
    # Interface for allowing containers to
    module Containable
      # A Containable Parent is an object which will act as the root/parent of
      # another containable, how the children are remembered by the parent
      # is solely up to the parent to decide
      module Parent
        # This method is called when a child as been adopted by the parent
        #
        # @param [Moon::RenderPrimitive::Containable] child
        # @abstract
        protected def on_child_adopt(child)
        end

        # Containers call this method to own a child container, if the child had
        # a parent previously, it will be {#orphan}ed
        #
        # @param [Moon::RenderPrimitive::Containable] child
        # @return [self]
        # @api public
        def adopt(child)
          child.orphan if child.parent
          child.parent = self
          on_child_adopt child
          self
        end

        # When a child has been disowned this method is called
        #
        # @param [Moon::RenderPrimitive::Containable] child
        # @abstract
        protected def on_child_disown(child)
        end

        # Containers call this method to disown a child container
        #
        # @param [Moon::RenderPrimitive::Containable] child
        # @return [self]
        # @api public
        def disown(child)
          if child.parent == self
            child.parent = nil
            on_child_disown child
          end
          self
        end
      end

      # @return [Moon::RenderPrimitive::Containable::Parent]
      attr_accessor :parent

      # Child containers call this method to detach themselves from the parent
      #
      # @return [self]
      def orphan
        parent.disown self if parent
        self
      end
    end
  end
end
