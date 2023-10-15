require 'test/unit'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/http_log_parser.rb"

require 'uri'

class ParserTest < Test::Unit::TestCase

  def setup
    @combined_line = '111.222.333.444 - - [21/Apr/2010:01:02:03 +0000] "GET /some/url?some=parameter HTTP/1.1" 302 123 "http://somewhere.com" "Browser (Version 1.0)"'
  end

  def assert_combined_line_is_correctly_parsed(parsed_data)
    assert_equal '111.222.333.444', parsed_data[:ip]
    assert_equal '111.222.333.444', parsed_data[:domain]
    assert_equal '-', parsed_data[:auth]
    assert_equal '-', parsed_data[:username]
    assert_equal '21/Apr/2010:01:02:03 +0000', parsed_data[:datetime]
    assert_equal 'GET /some/url?some=parameter HTTP/1.1', parsed_data[:request]
    assert_equal '302', parsed_data[:status]
    assert_equal '123', parsed_data[:bytecount]
    assert_equal 'http://somewhere.com', parsed_data[:referer]
    assert_equal 'Browser (Version 1.0)', parsed_data[:user_agent]

    assert_equal 11, parsed_data.size
  end

  def test_parser_creation_with_default_constructor_yields_a_HttpLogParser
    assert_true HttpLogParser.new.is_a? HttpLogParser
  end

  def test_parser_creation_with_default_constructor_has_5_formats
    assert_equal 5, HttpLogParser.new.formats.size
  end

  def test_parser_initialized_with_string_has_an_only_format
    assert_equal 1, HttpLogParser.new('%h %l %u %t \"%r\" %>s %b').formats.size
  end

  def test_parser_initialized_with_hash_has_all_its_formats_and_nothing_more
    parser = HttpLogParser.new({
      :common => '%h %l %u %t \"%r\" %>s %b',
      :common_with_virtual => '%v %h %l %u %t \"%r\" %>s %b',
    })
    assert_equal 2, parser.formats.size
    assert_equal parser.formats[:common].format, '%h %l %u %t \"%r\" %>s %b'
    assert_equal parser.formats[:common_with_virtual].format, '%v %h %l %u %t \"%r\" %>s %b'
  end

  def test_default_constructor_initialize_directives_with_common_default_apache_directive
    parser = HttpLogParser.new
    assert_true parser.formats.keys.include? :common
    assert_equal '%h %l %u %t \"%r\" %>s %b', parser.formats[:common].format
  end

  def test_simple_parsing_with_defaults_formats_parse_line_that_match_a_format
    parser = HttpLogParser.new
    parsed = parser.parse_line @combined_line
    assert_combined_line_is_correctly_parsed parsed
  end

  def test_initializing_with_explicits_formats_with_combined_directive_can_parse_a_combined_directive_formatted_line
    parser = HttpLogParser.new({
        :common => '%h %l %u %t \"%r\" %>s %b',
        :combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    })
    parsed = parser.parse_line @combined_line
    assert_combined_line_is_correctly_parsed parsed
  end

  # def test_large_log
  #   parser = HttpLogParser.new
  #   assert_not_nil parser
  #   File.open('.../log/access.log', 'r:ascii-8bit') do |file|
  #     while(line = file.gets)
  #       parsed_data = parser.parse_line(line)
  #     end
  #   end
  # end

end
