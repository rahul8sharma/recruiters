class Suitability::ItemGroupsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "admin"
  
  def import_from_google_drive
    errors = Vger::Resources::Suitability::ItemGroup.import_from_google_drive(params[:item_group])
    redirect_to manage_suitability_item_groups_url, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def manage
  end
  
  def index
    @items = Vger::Resources::Suitability::Item.where(:page => params[:page], :per => 10, :methods => [:options])
  end
end
