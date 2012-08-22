class SuperGrabbingModule < Module

  def initialize(options)
    forward_object = options.fetch(:forward_to)

    grabbing_module = self
    options.fetch(:methods, []).each do |method_name|
      module_eval do
        define_method(method_name) do |*args|
          if grabbing_module.on?
            forward_object && forward_object.send(method_name, *args)
          else
            super(*args)
          end
        end
      end
    end
    on
  end

  def on?
    @on
  end

  def off?
    !on?
  end

  def on
    @on = true
  end

  def off
    @on = false
  end
end
