require File.dirname(__FILE__) + '/../../test_helper'

class StringTest < Test::Unit::TestCase

  def test_should_return_itself_in_SHA1_when_sent_to_sha1
    assert_equal Digest::SHA1.hexdigest('string'), 'string'.to_sha1
  end

end

