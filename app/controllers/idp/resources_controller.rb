class Idp::ResourcesController < MasterDataController
  def api_resource
    Vger::Resources::Idp::Resource
  end
end
