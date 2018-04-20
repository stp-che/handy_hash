require 'active_support/all'

class HandyHash < HashWithIndifferentAccess
  VERSION = '0.1.0'

  class ValueMissingError < StandardError; end

  def initialize(value=nil)
    if value
      value.each do |k, v|
        self[k] = __wrap v
      end
    end
  end

  def freeze
    super
    each{|_, v| v.freeze unless v.frozen?}
  end

  def []=(k,v)
    super k, __wrap(v)
  end

  def patch(hash=nil, &block)
    change_set = [].tap do |ch|
      ch << __wrap(hash) if hash
      ch << Builder.new(&block).data if block_given?
    end
    Patch.(self, *change_set)
  end

  def method_missing(m, *args, &block)
    if m =~ /\Ato_ary\Z/ || m =~ /\=$/ || args.size > 1 || block_given?
      super
    else
      m = m.to_s
      if m[-1] == '!'
        m = m.to_s.sub!(/!$/, '')
        required = true
      end
      if m =~ /\A_(.+)_\Z/
        m = $1 
      end
      __fetch_value m, required: required, default: args.first
    end
  end

  private

  def __fetch_value(key, required: false, default: nil)
    self[key] || default || (required ? raise(ValueMissingError, "value missing: \"#{key}\"") : HandyHash.Nil)
  end

  def __wrap(v)
    v.kind_of?(Hash) && !v.kind_of?(HandyHash) ? HandyHash.new(v) : v
  end

  class << self
    def Nil
      @Nil ||= new.tap(&:freeze)
    end
  end

  # @api private
  class Patch
    class << self
      def call(orig_data, *change_set)
        change_set.inject(orig_data){|data, changes| deep_merge(data, changes) }
      end

      private

      def deep_merge(h1, h2)
        HandyHash.new({}).tap do |d|
          h1.each{|k,v|
            unless h2.key?(k)
              d[k] = v
            else
              if v.kind_of?(Hash) && h2[k].kind_of?(Hash)
                d[k] = call(v, h2[k])
              else
                d[k] = h2[k]
              end
            end
          }
          h2.each{|k,v|
            next if h1.key?(k)
            d[k] = v
          }
        end
      end
    end
  end

  # @api private
  class Builder
    def initialize(&block)
      @content = {}
      instance_eval &block if block_given?
    end

    def method_missing(m, *args, &block)
      if m =~ /\Ato_ary\Z/ || m =~ /\=$/ || args.size > 1
        super
      else
        m = m.to_s
        if m =~ /\A_(.+)_\Z/
          m = $1 
        end
        if args.empty?
          @content[m] = Builder.new(&block)
        else
          @content[m] = args.first
        end
      end
    end

    def data
      HandyHash.new.tap do |d|
        @content.each do |k, v|
          d[k] = v.kind_of?(Builder) ? v.data : v
        end
      end
    end
  end

end
