class Payment < ActiveRecord::Base

  attr_accessor :reasons

  belongs_to :user
  belongs_to :account
  has_many :invoices, 
    :dependent => :destroy

  validates_presence_of :user, 
    :account
  validates_numericality_of :amount

  validate_on_create :positive_amount,
    :available_credit_balance
  before_create :mark_as_pending
  after_create :email_admins
  after_destroy :send_cancellation_email

  def pending?
    status == 'Pending'
  end

  def accepted?
    status == 'Accepted'
  end

  def processed?
    status == 'Processed'
  end

  def rejected?
    status == 'Rejected'
  end

  def amount_due
    amount - invoices.inject(0) {|sum, each| sum + each.amount}
  end

  def paid_off?
    amount_due.zero?
  end

  def accept!
    update_attribute :status, 'Accepted'
    PaymentsMailer.deliver_payment_accepted self
  end

  def reject!
    update_attribute :status, 'Rejected'
    PaymentsMailer.deliver_payment_rejected self
  end

  def to_pdf
    pdf = PDF::Writer.new
    pdf.select_font 'Times-Roman'
    pdf.margins_in 1

    pdf.text %Q{<b>Direction For</b>\n\n}, :justification => :center
    pdf.text %Q{<b>Research Service Payment</b>\n\n}, :justification => :center
    pdf.text %Q{<b>To:  The Williams Capital Group, L.P. ("Williams")</b>\n\n}
    pdf.text %Q{<b>From:  #{account.company.name} ("division of BNY Mellon N.A.")</b>\n\n}
    pdf.text %Q{Please make payment in the amount of #{'$%.2f' % amount} to #{account.organization.name} ("Research Provider") for the following research services ("Research Services").\n\n}
    pdf.text "Describe in detail the Research Service(s):\n\n"
    unless reasons.nil?
      reasons.each do |each|
        pdf.text "\t\t<C:disc />\t#{each}\n\n"
      end
    end
    pdf.text %Q{\n<b>Research Provider</b>.    Research Provider acknowledges and agrees that all payments under this Direction and any subsequent Direction relating to Research Services are and will be inclusive of any applicable tax and are and will be in full and final settlement of the obligations to which such payment relates. Research Provider acknowledges and agrees that it shall have no further recourse to Williams in respect of the payment for the Research Services to which a payment relates.  Research Provider represents and warrants that it has, and at all relevant times will have, full power, authority and all necessary licenses (including any investment advisory registration) to engage as a Research Provider and receive payment under a Direction.  Non Broker Dealer Research Providers Acknowledge that the services provided, qualifies under the Safe Harbor exemption as set forth in Section 28(e) of the Exchange Act.  Research Provider shall idemnify and hold harmless Williams, and Williams' respective affiliates, directors, officers, members, partners, employees and agents, against any and all liabilities arising as a result of any breach of the foregoing representations and warranties.}
    pdf.text %Q{\n\n<b>Acknowledged and Agreed:</b>}, :justification => :right
    pdf.text %Q{\n<b>    Research Provider #{account.organization.name}:</b>\n\n}, :justification => :right
    pdf.text %q{By: ____________________________}, :justification => :right
    pdf.text %q{Printed Name: ____________________________}, :justification => :right
    pdf.text %q{Title: ____________________________}, :justification => :right
    pdf.text %q{Address: ____________________________}, :justification => :right
    pdf.text %q{________________________________}, :justification => :right
    pdf.text %q{________________________________}, :justification => :right    

    unless user.picture.nil?
      pdf.new_page
      pdf.image user.picture.full_filename
    end
    pdf
  end

 protected

  def available_credit_balance
    unless account.nil? ||
        amount.nil?
      unless account.company.cover?(amount)
        errors.add_to_base "#{account.company.name} does not have that much credit available"
      end
    end
  end

  def positive_amount
    unless amount.nil? 
      unless amount > 0
        errors.add :amount, "can't be negative or zero"
      end
    end
  end

  def mark_as_pending
    self.status = 'Pending'
  end

  def email_admins
    PaymentsMailer.deliver_payment_request self 
  end

  def send_cancellation_email
    PaymentsMailer.deliver_payment_cancelled self
  end

end
 
