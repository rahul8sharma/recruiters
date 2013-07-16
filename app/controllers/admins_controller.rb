class AdminsController < ApplicationController
  before_filter :authenticate_user!

  def import
		Vger::Resources::Admin.import(params[:file])
		redirect_to admins_path, notice: "Admins imported."
	end	

  # GET /admins
  def index
  	@admins = Vger::Resources::Admin.all
  end

  # GET /admins/new
  # GET /admins/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin }
    end
  end
end
