class BaseEvent
  attr_reader :metadata

  def initialize(**attributes)
    @attributes = attributes
    @metadata = {}
    define_attribute_accessors
  end

  def event_name
    self.class.name.underscore.tr("/", ".").concat(".v1")
  end

  private

  def define_attribute_accessors
    @attributes.each_key do |key|
      self.class.attr_reader(key) unless self.class.method_defined?(key)
      instance_variable_set("@#{key}", @attributes[key])
    end
  end
end
