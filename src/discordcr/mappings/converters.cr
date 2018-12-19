require "json"
require "time/format"

module Discord
  # :nodoc:
  module TimestampConverter
    def self.from_json(parser : JSON::PullParser)
      time_str = parser.read_string

      begin
        Time::Format.new("%FT%T.%6N%:z").parse(time_str)
      rescue Time::Format::Error
        Time::Format.new("%FT%T%:z").parse(time_str)
      end
    end

    def self.to_json(value : Time, builder : JSON::Builder)
      Time::Format.new("%FT%T.%6N%:z").to_json(value, builder)
    end
  end

  # :nodoc:
  module MaybeTimestampConverter
    def self.from_json(parser : JSON::PullParser)
      if parser.kind == :null
        parser.read_null
        return nil
      end
      TimestampConverter.from_json(parser)
    end

    def self.to_json(value : Time?, builder : JSON::Builder)
      if value
        TimestampConverter.to_json(value, builder)
      else
        builder.null
      end
    end
  end

  # The stdlib `Enum.from_json(string_or_io)` constructs an enum member instance
  # by using the strict `Enum.from_value(int)` class method. This can be
  # problematic for enums in Discord's API because:
  #
  #   - Undocumented values for enums may be observed, not intended to be
  #     understood by clients.
  #
  #   - Established enums may have members added to them within the current API
  #     version.
  #
  # In both cases, using `Enum.from_value(int)` will raise, causing any object
  # that implements them to fail to parse the enum.
  #
  # This converter defers to the *non-strict* `Enum.new` constructor, given the
  # enum as `T` and the enums base type as `U`, so that this exception is not
  # raised in the event of undocumented enum members, or an update to an enum
  # definition.
  # :nodoc:
  module EnumConverter(T, U)
    def self.from_json(parser : JSON::PullParser) : T
      {% raise "T must be an enum" unless T < Enum %}
      int_value = parser.read_int
      {% if U == Int32 %}
        T.new(int_value.to_i32)
      {% elsif U == UInt8 %}
        T.new(int_value.to_u8)
      {% elsif U == UInt64 %}
        T.new(int_value.to_u64)
      {% else %}
        {% raise "EnumConverter unhandled base type: #{T}" %}
      {% end %}
    end

    def self.to_json(value : T, builder : JSON::Builder)
      value.to_json(builder)
    end
  end
end
