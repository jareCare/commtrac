module Admin::InvoicesHelper

  def available_accounts
    accounts = Account.find :all, :order => 'number'
    accounts.collect do |each| 
      [h("#{each.company.name} / #{each.organization.name}"), each.id]
    end
  end

  def group_by_company(invoices)
    invoices.group_by {|each| each.payment.account.company}
  end

end
