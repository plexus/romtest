require 'set'


module Pretty
  def pretty(formatted = Set.new)
    return "#{self.class}(#{(object_id % 2**20).to_s(16).upcase}...)" if formatted.include?(self)
    formatted << self

    indent = ->(str) { str.lines.map {|l| "  #{l}"}.join }
    ivars  = -> { instance_variables.each_with_object({}) {|i, h| h[i.to_s] = instance_variable_get(i)} }

    format = ->(val) do
      if val.respond_to?(:pretty)
        begin
          val.pretty(formatted)
        rescue
          val.pretty
        end
      else
        val.inspect
      end
    end

    values = case
             when respond_to?(:to_h_compact)
               to_h_compact
             when respond_to?(:to_h)
               to_h rescue ivars[]
             else
               ivars[]
             end

    if values.empty?
      if instance_variables.any?
        values = ivars[]
      else
        return self.inspect
      end
    end

    fmt_attrs = values.map do |attr, value|
      fmt_val = case value
                when Array
                  if value.inspect.length < 50
                    "[#{value.map(&format).join(", ")}]"
                  else
                    "[\n#{indent[value.map(&format).join(",\n")]}\n]"
                  end
                when Hash
                  syms = value.keys.all? { |k| k.is_a? Symbol }
                  pairs = value.map do |k, v|
                    if syms
                      "#{k}: #{format[v]}"
                    else
                      "#{format[k]} => #{format[v]}"
                    end
                  end
                  if pairs.join(", ").length < 48
                    "{#{pairs.join(", ")}}"
                  else
                    "{\n#{indent[pairs.join(",\n")]}}\n"
                  end
                else
                  format[value]
                end
      "#{attr}: #{fmt_val}"
    end

    fmt_attrs_str = fmt_attrs.join(", ")

    if fmt_attrs_str.length > 50
      fmt_attrs_str = fmt_attrs.join(",\n")
    end

    if fmt_attrs_str =~ /\n/
      fmt_attrs_str = "\n#{indent[fmt_attrs_str]}\n"
    end

    case
    when is_a?(Hash)
      "{#{fmt_attrs_str}}"
    when is_a?(Array)
      if inspect.length < 50
        "[#{map(&format).join(", ")}]"
      else
        "[\n#{indent[map(&format).join(",\n")]}\n]"
      end
    else
      "#{self.class.name}(#{fmt_attrs_str})"
    end
  end
end


class Object
  include Pretty
end

[Symbol, TrueClass, FalseClass, String, Method, NilClass, Class, Proc].each do |klass|
  klass.class_eval do
    def pretty
      inspect
    end
  end
end

def hr
  puts "-" * 60
end

def show(code)
  puts "> #{code}"
  TOP.eval(code).tap do |result|
    puts "=> #{result.pretty}"
  end
end
