class Idp::CommentsController < MasterDataController
  def api_resource
    Vger::Resources::Idp::Comment
  end
end
