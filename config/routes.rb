ActionController::Routing::Routes.draw do |map|

  map.connect '', :controller => 'companies'

  map.resources :companies do |company|
    company.resources :users do |user|
      user.resource :picture,
        :controller => 'users/picture',
        :name_prefix => 'user_'
    end
    company.resources :payments
    company.resources :accounts
    company.resources :trades
    company.resources :invoices do |invoice|
      invoice.resource :picture, 
        :controller => 'invoices/picture',
        :name_prefix => 'invoice_'
    end
  end
  map.resources :organizations

  map.resources :passwords
  map.resources :reminders
  map.resource :session

  map.resources :companies,
    :controller => 'admin/companies',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :users,
    :controller => 'admin/users',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :accounts,
    :controller => 'admin/accounts',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :invoices,
    :controller => 'admin/invoices',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :passwords,
    :controller => 'admin/passwords',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :payments,
    :controller => 'admin/payments',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :pictures,
    :controller => 'admin/pictures',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'
  map.resources :trades,
    :controller => 'admin/trades',
    :path_prefix => 'admin',
    :name_prefix => 'admin_',
    :collection => { :search => :get }
  map.resources :organizations,
    :controller => 'admin/organizations',
    :path_prefix => 'admin',
    :name_prefix => 'admin_'

end
