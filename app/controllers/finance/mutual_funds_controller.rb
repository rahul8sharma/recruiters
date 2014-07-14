class Finance::MutualFundsController < MasterDataController
  def api_resource
    Vger::Resources::Finance::MutualFund
  end

  def index_columns
    [:id, :uid, :name]
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id, :uid, :name]
  end
end
