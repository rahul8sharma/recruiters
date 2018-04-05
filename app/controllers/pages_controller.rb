class PagesController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  def home
  end
end
