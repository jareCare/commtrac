require File.dirname(__FILE__) + '/../test_helper'
require 'reminders_mailer'

class RemindersMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :users

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_should_create_an_email_to_the_given_user_when_sent_create_password_reminder
    email = RemindersMailer.create_password_reminder users(:user_one)

    assert_equal users(:user_one).email, email.to.first
    assert_equal 'do-not-reply@nutmegcommtrac.com', email.from.first
    assert_match %r{http://#{HOST}/passwords/new}, email.body
    assert_match %r{_u=1}, email.body
    assert_match %r{_p=#{users(:user_one).password}}, email.body
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/reminders_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
