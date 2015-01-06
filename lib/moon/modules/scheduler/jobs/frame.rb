module Moon
  class Scheduler
    module Jobs
      class Frame < Base
        attr_accessor :complete

        def on_timeout
          @complete.call if @complete
        end

        def update_frame(delta)
          @callback.call(delta) if @callback
        end
      end
    end
  end
end
