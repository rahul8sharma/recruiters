class Idp::TasksController < MasterDataController
  def api_resource
    Vger::Resources::Idp::Task
  end
  
  def index_columns
    ['name','deadline','status']
  end
end
