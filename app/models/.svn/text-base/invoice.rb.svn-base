class Invoice < ActiveRecord::Base

  belongs_to :payment
  has_one :picture, 
    :as => :subject

  validates_presence_of :number,
    :start_date,
    :end_date,
    :check_number,
    :paid_on,
    :payment
  validates_numericality_of :amount

  validate :available_credit_balance,
    :service_date_range,
    :positive_amount,
    :over_invoicing
  after_create :set_payment_processed_on_date

  def self.search(company, options)
    if options[:vendors] && 
        options[:brokers]
      organization_ids = options[:vendors].collect {|each| each.id} +
        options[:brokers].collect {|each| each.id}
      organization_types = Organization::TYPES
    else
      if options[:vendors] 
        organization_ids = options[:vendors].collect {|each| each.id}
        organization_types = 'Vendor'
      end
      if options[:brokers] 
        organization_ids = options[:brokers].collect {|each| each.id}
        organization_types = 'Broker'
      end
    end

    find :all,
      :select => 'invoices.*',
      :joins => 'inner join payments on payments.id = invoices.payment_id
                 inner join accounts on accounts.id = payments.account_id
                 inner join organizations on organizations.id = accounts.organization_id',
      :conditions => ['account_id in (?)
                       and paid_on between ? and ?
                       and organization_id in (?)
                       and organization_type in (?)',
                      company.accounts.collect {|each| each.id},
                      options[:time_span].begin,
                      options[:time_span].end,
                      organization_ids,
                      organization_types]
  end

 protected

  def available_credit_balance
    unless amount.nil? ||
        payment.nil? 
      unless payment.account.company.cover?(amount)
        errors.add :amount, "#{payment.account.company.name} doesn't have enough credit available"
      end
    end
  end

  def service_date_range
    unless start_date.nil? ||
      end_date.nil? 
      if start_date > end_date
        errors.add_to_base 'Invalid service date'
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

  def over_invoicing
    unless amount.nil? ||
        payment.nil? 
      unless amount <= payment.amount_due 
        errors.add :amount, 'is more than the total amount due'
      end
    end
  end

  def set_payment_processed_on_date
    payment.reload
    if payment.paid_off?
      payment.update_attributes(:status => 'Processed',
                                :processed_on => created_on)
    end
  end

end
