class ActiveRecord::Base
def attr_accessible(*attributes)
    @attr_accessible ||= []
    @attr_accessible |= attributes
  end
  
  def attr_protected(*attributes)
    @attr_protected ||= []
    @attr_protected |= attributes
  end
end
