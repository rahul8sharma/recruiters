class Functional::TraitScoreBucketsController < MasterDataController
  def api_resource
    Vger::Resources::Functional::TraitScoreBucket
  end

  def import_from
    "import_from_google_drive"
  end

  def index_columns
    [:id,:uid,:norm_bucket_id, :min_val, :max_val]
  end

end



