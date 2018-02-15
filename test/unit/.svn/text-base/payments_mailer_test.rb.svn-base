require File.dirname(__FILE__) + '/../test_helper'
require 'payments_mailer'

class PaymentsMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :users, 
    :accounts, 
    :companies, 
    :organizations,
    :payments

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_should_create_an_email_to_the_admin_about_the_given_payment_when_sent_create_payment_request
    PDF::Writer.
      any_instance.
      expects(:image).
      times(2)
    File.
      stubs(:read).
      returns('')

    payment = Payment.create! :user => users(:user_two),
      :account => accounts(:company_one_vendor_one),
      :amount => 1,
      :request => 'request'

    email = PaymentsMailer.create_payment_request payment

    assert_equal User.admins.collect {|each| each.email}, email.to
    assert_equal 'do-not-reply@williamscommtrac.com', email.from.first
    assert_equal 'Payment Request', email.subject
  end

  def test_should_create_an_email_to_the_user_who_made_the_given_rejected_payment_when_sent_create_payment_rejected
    payment = Payment.new :user => users(:user_two),
    :account => accounts(:company_one_vendor_one),
    :amount => 1,
    :status => 'Rejected',
    :response => "Don't worry about this.",
    :created_on => Time.local(2007, 1, 1)

    email = PaymentsMailer.create_payment_rejected payment

    assert_equal payment.user.email, email.to.first
    assert_equal 'do-not-reply@williamscommtrac.com', email.from.first
    assert_equal 'Payment Rejected', email.subject
    assert_equal read_fixture('payment_rejected.rhtml').to_s, email.body
  end

  def test_should_create_an_email_to_the_user_who_made_the_given_accepted_payment_when_sent_create_payment_accepted
    payment = Payment.new :user => users(:user_two),
    :account => accounts(:company_one_vendor_one),
    :amount => 1,
    :status => 'Accepted',
    :response => 'Thanks a lot.',
    :created_on => Time.local(2007, 1, 1)

    email = PaymentsMailer.create_payment_accepted payment

    assert_equal payment.user.email, email.to.first
    assert_equal 'do-not-reply@williamscommtrac.com', email.from.first
    assert_equal 'Payment Accepted', email.subject
    assert_equal read_fixture('payment_accepted.rhtml').to_s, email.body
  end

  def test_should_create_an_email_to_all_admins_about_the_cancellation_of_the_given_payment_when_sent_create_payment_cancelled
    payment = payments :user_two_company_one_vendor_one_account

    email = PaymentsMailer.create_payment_cancelled payment

    assert_equal User.admins.collect {|each| each.email}, email.to
    assert_equal 'do-not-reply@williamscommtrac.com', email.from.first
    assert_equal 'Payment Cancelled', email.subject
    assert_equal read_fixture('payment_cancelled.rhtml').to_s, email.body
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/payments_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
