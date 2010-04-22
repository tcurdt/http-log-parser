require File.expand_path(File.dirname(__FILE__) + '/test_helper')

require 'uri'

class ParserTest < Test::Unit::TestCase
  
  def test_parser_creation

    parser = HttpLogParser.new
    assert_not_nil parser
    assert_equal 5, parser.formats.size

    parser = HttpLogParser.new('%h %l %u %t \"%r\" %>s %b')    
    assert_not_nil parser
    assert_equal 1, parser.formats.size

    parser = HttpLogParser.new({
      :common => '%h %l %u %t \"%r\" %>s %b',
      :common_with_virtual => '%v %h %l %u %t \"%r\" %>s %b',
    })   
    assert_not_nil parser
    assert_equal 2, parser.formats.size

  end

  def test_simple_parsing

    parser = HttpLogParser.new
    assert_not_nil parser

    parsed = parser.parse_line('111.222.333.444 - - [21/Apr/2010:01:02:03 +0000] "GET /some/url?some=parameter HTTP/1.1" 302 123 "http://somewhere.com" "Browser (Version 1.0)"')

    assert_equal '111.222.333.444', parsed[:ip]
    assert_equal '111.222.333.444', parsed[:domain]
    assert_equal '-', parsed[:auth]
    assert_equal '-', parsed[:username]
    assert_equal '21/Apr/2010:01:02:03 +0000', parsed[:datetime]
    assert_equal 'GET /some/url?some=parameter HTTP/1.1', parsed[:request]
    assert_equal '302', parsed[:status]
    assert_equal '123', parsed[:bytecount]
    assert_equal 'http://somewhere.com', parsed[:referer]
    assert_equal 'Browser (Version 1.0)', parsed[:user_agent]

    assert_equal 11, parsed.size

  end
  
end