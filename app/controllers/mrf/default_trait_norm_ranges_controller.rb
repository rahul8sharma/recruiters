class Mrf::DefaultTraitNormRangesController < MasterDataController

  def api_resource
      Vger::Resources::Mrf::DefaultTraitNormRange
    end

    def import_from
      "import_from_google_drive"
    end

    def index_columns
      [:id,:trait_id,:trait_type,:from_norm_bucket_id,:to_norm_bucket_id]
    end

end
