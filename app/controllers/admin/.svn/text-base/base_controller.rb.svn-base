class Admin::BaseController < ApplicationController

  before_filter :admin?

  def admin?
    unless current_user.admin?
      redirect_to home_url
    end
  end

end
