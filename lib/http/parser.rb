# class that defines the actual log format
class HttpLogFormat
  attr_reader :name, :format, :format_symbols, :format_regex

  DIRECTIVES = {
    'h' => [:ip, /\d+\.\d+\.\d+\.\d+/],
    'l' => [:auth, /.*?/],
    'u' => [:username, /.*?/],
    't' => [:datetime, /\[.*?\]/],
    'r' => [:request, /.*?/],
    's' => [:status, /\d+/],
    'b' => [:bytecount, /-|\d+/],
    'v' => [:domain, /.*?/],
    'i' => [:header_lines, /.*?/],
    'e' => [:errorlevel, /\[.*?\]/],
  }

  def initialize(name, format)
    @name, @format = name, format
    parse_format(format)
  end

  def parse_format(format)
    format_directive = /%(.*?)(\{.*?\})?([#{[DIRECTIVES.keys.join('|')]}])([\s\\"]*)/

    log_format_symbols = []
    format_regex = ""
    format.scan(format_directive) do |condition, subdirective, directive_char, ignored|
      log_format, match_regex = process_directive(directive_char, subdirective, condition)
      ignored.gsub!(/\s/, '\\s') unless ignored.nil?
      log_format_symbols << log_format
      format_regex << "(#{match_regex})#{ignored}"
    end
    @format_symbols = log_format_symbols
    @format_regex =  /^#{format_regex}/
  end

  def process_directive(directive_char, subdirective, condition)
    directive = DIRECTIVES[directive_char]
    case directive_char
    when 'i'
      log_format = subdirective[1...-1].downcase.tr('-', '_').to_sym
      [log_format, directive[1].source]
    else
      [directive[0], directive[1].source]
    end
  end
end

# parser class that detects the log format and creates a hash of the data per line
class HttpLogParser

  LOG_FORMATS = {
    :common => '%h %l %u %t \"%r\" %>s %b',
    :common_with_virtual => '%v %h %l %u %t \"%r\" %>s %b',
    :combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_virtual => '%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_cookies => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Cookies}i\"'
  }

  attr_reader :formats

  def initialize(formats = nil)

    case formats
      when Hash then
        @formats = {}
        formats.each do |name, format|
          @formats[name] = HttpLogFormat.new(name, format)
        end
      when String then
        initialize({:provided => formats})
      when nil
        initialize LOG_FORMATS
    end

  end

  def format_from_line(line)
    @formats.sort_by { |key, format| format.format_regex.source.size }.reverse.each { |key, format|
      return @formats[key] if line.match(format.format_regex)
    }
    raise "Failed to detect format"
  end

  def parse_line(line)

    @format ||= format_from_line(line)

    raise "Line does not match format" if line !~ @format.format_regex

    data = line.scan(@format.format_regex).flatten
    parsed_data = {}
    @format.format_symbols.size.times do |i|
      parsed_data[@format.format_symbols[i]] = data[i]
    end

    parsed_data[:datetime] = parsed_data[:datetime][1...-1] if parsed_data[:datetime]
    parsed_data[:domain] = parsed_data[:ip] unless parsed_data[:domain]
    parsed_data[:format] = @format

    parsed_data
  end
end
