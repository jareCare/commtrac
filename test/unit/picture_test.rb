require File.dirname(__FILE__) + '/../test_helper'

class PictureTest < Test::Unit::TestCase

  fixtures :invoices, 
    :accounts, 
    :pictures,
    :companies, 
    :users

  def test_should_be_associated_with_a_subject
    picture = Picture.new

    assert_respond_to picture, :subject
  end

  def test_should_use_attachment_fu
    picture = Picture.new

    assert_respond_to picture, :uploaded_data
  end

end
