class PaymentsMailer < ActionMailer::Base

  default_url_options[:host] = HOST

  def payment_request(payment)
    recipients User.admins.collect {|each| each.email}
    from 'do-not-reply@williamscommtrac.com'
    subject 'Payment Request'
    body :payment => payment

    attachment :content_type => 'application/pdf',
      :body => payment.to_pdf.to_s,
      :filename => 'payment.pdf'
  end

  def payment_rejected(payment)
    recipients payment.user.email
    from 'do-not-reply@williamscommtrac.com'
    subject 'Payment Rejected'
    body :payment => payment
  end

  def payment_accepted(payment)
    recipients payment.user.email
    from 'do-not-reply@williamscommtrac.com'
    subject 'Payment Accepted'
    body :payment => payment
  end

  def payment_cancelled(payment)
    recipients User.admins.collect {|each| each.email}
    from 'do-not-reply@williamscommtrac.com'
    subject 'Payment Cancelled'
    body :payment => payment
  end

end
