class Mrf::DefaultCompetencyNormRangesController < MasterDataController

  def api_resource
      Vger::Resources::Mrf::DefaultCompetencyNormRange
    end

    def import_from
      "import_from_google_drive"
    end

    def index_columns
      [:id,:competency_id,:from_norm_bucket_id,:to_norm_bucket_id]
    end

end
