class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  layout "admin"
      
  def import
    Vger::Resources::Subscription.import(params[:file])
    redirect_to subscriptions_path, notice: "Subscriptions imported."
  end  
  
  def manage
  end
  
  def import_from_google_drive
    Vger::Resources::Subscription\
      .import_from_google_drive(params[:import])
    redirect_to subscriptions_path, notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end

  def export_to_google_drive
    Vger::Resources::Subscription\
      .export_to_google_drive(params[:export].merge(:columns => ["id","name"]))
    redirect_to subscriptions_path, notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end

  def index
    @subscriptions = Vger::Resources::Subscription.where(:page => params[:page], :per => 10)
  end
end
