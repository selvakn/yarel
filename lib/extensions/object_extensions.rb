module ObjectExtensions
  def deep_clone
    Marshal.load( Marshal.dump(self))
  end
end

Object.send :include, ObjectExtensions