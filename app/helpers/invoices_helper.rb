module InvoicesHelper

  def group_by_organization(invoices)
    invoices.group_by {|each| each.payment.account.organization}
  end

  def available_organizations
    organizations = current_user.company.organizations.find :all,
      :order => 'name'
    organizations.collect {|each| [each.name, each.id]}
  end

end
