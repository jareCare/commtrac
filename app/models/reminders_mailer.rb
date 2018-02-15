class RemindersMailer < ActionMailer::Base

  default_url_options[:host] = HOST

  def password_reminder(user)
    recipients user.email
    from 'do-not-reply@williamscommtrac.com'
    subject 'Reset your password'
    body :user => user
  end

end
