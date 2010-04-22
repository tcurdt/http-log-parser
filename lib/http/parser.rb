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

class HttpLogParser

  LOG_FORMATS = {
    :common => '%h %l %u %t \"%r\" %>s %b',
    :common_with_virtual => '%v %h %l %u %t \"%r\" %>s %b',
    :combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_virtual => '%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_cookies => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Cookies}i\"'
  }

  attr_reader :known_formats

  def initialize
    @log_format = []
    initialize_known_formats
  end

  def initialize_known_formats
    @known_formats = {}
    LOG_FORMATS.each do |name, format|
      @known_formats[name] = HttpLogFormat.new(name, format)
    end
  end

  def check_format(line)
    @known_formats.sort_by { |key, log_format| log_format.format_regex.source.size }.reverse.each { |key, log_format|
      return key if line.match(log_format.format_regex)
    }
    return :unknown
  end

  def parse_line(line)
    @format = check_format(line)
    log_format = @known_formats[@format]
    raise ArgumentError if log_format.nil? or line !~ log_format.format_regex
    data = line.scan(log_format.format_regex).flatten
    parsed_data = {}
    log_format.format_symbols.size.times do |i|
      parsed_data[log_format.format_symbols[i]] = data[i]
    end

    parsed_data[:datetime] = parsed_data[:datetime][1...-1] if parsed_data[:datetime]
    parsed_data[:domain] = parsed_data[:ip] unless parsed_data[:domain]
    parsed_data[:format] = @format

    parsed_data
  end
end
