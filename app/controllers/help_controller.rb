class HelpController < ApplicationController
  layout "help"
  before_filter :authenticate_user!
  def adding_candidates
  end
end
