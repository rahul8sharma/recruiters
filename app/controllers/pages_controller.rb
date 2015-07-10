class PagesController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'

  def home
  end
end
