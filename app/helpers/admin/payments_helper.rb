module Admin::PaymentsHelper

  def group_by_company(payments)
    payments.group_by {|each| each.account.company}
  end

end
