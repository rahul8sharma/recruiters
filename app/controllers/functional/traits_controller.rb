class Functional::TraitsController < MasterDataController
  def api_resource
    Vger::Resources::Functional::Trait
  end

  def index
    params[:type] ||= "Functional::Trait"
    @traits = Vger::Resources::Functional::Trait.where(
      :methods => [:company_ids],
      :page => params[:page],
      :per => 50,
      :root => :trait
    ).all
  end

  def index_columns
    [:id, :name]
  end

  def import_from
    "import_from_google_drive"
  end


end
