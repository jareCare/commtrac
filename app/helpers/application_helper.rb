module ApplicationHelper

  def you?(user)
    user == current_user
  end

  def format_execution_type(execution_type)
    execution_types = {
      'AUTO' => 'Auto',
      'SOFT' => 'CSA',
      'BEST' => 'Non-CSA'
    }
    execution_types[execution_type]
  end

  def sort_by_created_on(payments)
    payments.sort_by {|each| each.created_on}
  end

  def sort_by_updated_on(payments)
    payments.sort_by {|each| each.updated_on}
  end

  def sort_by_processed_on(payments)
    payments.sort_by {|each| each.processed_on}
  end

  def available_accounts
    accounts = current_user.company.accounts.find :all
    accounts.collect {|each| [each.organization.name, each.id]}
  end

  def available_reasons
    ['traditional research reports analyzing the performance of a company or stock',
      'certain financial newsletters',
      'certain trade journals',
      'quantitative analytical software',
      'software that provides analyses of securities portfolios',
      'seminars and conferences (but not associated travel expenses, entertainment and meals)',
      'market data such as stock quotes, last sale prices, and trading volumes',
      'company financial data and economic data (e.g., unemployment and inflation rates, gross domestic product)',
      "consultant's services addressing eligible topics (e.g., portfolio strategy)"]
  end

  def available_execution_types
    [%w(All All), 
     %w(Auto AUTO),
     %w(CSA SOFT),
     %w(Non-CSA BEST)]
  end

  def group_by_company(accounts)
    accounts.group_by {|each| each.company}
  end

  def group_by_organization(accounts)
    accounts.group_by {|each| each.organization}
  end

  def sort_by_organization_name(accounts)
    accounts.sort_by {|each| each.organization.name}
  end

  def available_companies
    companies = Company.find :all, :order => 'name'
    companies.collect {|each| [each.name, each.id]}
  end

  def available_organizations
    organizations = Organization.find :all, :order => 'name'
    organizations.collect {|each| [each.name, each.id]}
  end

  def sort_by_paid_on(invoices)
    invoices.sort_by {|each| each.paid_on}
  end

  def total_amount(invoices)
    invoices.inject(0) {|sum, each| sum + each.amount}
  end

  def all_organizations
    [['', ''],
     ['All', 'All'], 
     ['All Brokers', 'All Brokers'], 
     ['All Vendors', 'All Vendors']]
  end

end
