module Moonr
  class JSBaseObject

    class << self
      attr_reader :properties
      attr_reader :internal_properties
    end

    @properties = []
    @internal_properties = []
    
    def self.property(prop)
      p prop
      p @properties
      properties << prop
    end

    def self.internal_property(prop)
      @internal_properties << prop
      attr_accessor prop   
    end

    property :class
    property :extensible

    def initialize
      @properties = {}
      self.class.properties.each { |p| @properties[p] = nil }
      self.class.internal_properties.each { |p| @internal_properties[p] = nil }
    end

    def get(name)
      @properties[name.to_sym]
    end
  end
end
