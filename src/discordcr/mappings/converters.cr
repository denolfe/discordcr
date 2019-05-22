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

  module TimeSpanMillisecondsConverter
    def self.from_json(parser : JSON::PullParser)
      parser.read_int.milliseconds
    end

    def self.to_json(value : Time::Span, builder : JSON::Builder)
      builder.scalar(value.milliseconds)
    end
  end

  # :nodoc:
  module MessageNonceConverter
    def self.from_json(parser : JSON::PullParser)
      kind = parser.kind
      case kind
      when :int
        parser.read_int
      when :string
        parser.read_string
      when :null
        parser.read_null
      else
        raise JSON::ParseException.new(
          "Unexpected nonce value: #{parser.read_raw} (#{kind})",
          parser.line_number,
          parser.column_number
        )
      end
    end

    def self.to_json(value : Int64 | String | Nil, builder : JSON::Builder)
      builder.scalar(value)
    end
  end
end
