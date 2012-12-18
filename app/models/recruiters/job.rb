class Recruiters::Job < Ohm::Model

  include Ohm::DataTypes
  include Ohm::Timestamps
  include Ohm::Callbacks
  
  attribute :other, Type::Hash

  attribute :status, Type::Integer
  attribute :posted_by, Type::Integer
  attribute :uuid
  
  index :status
  index :posted_by
  index :uuid

  def create(data)
    super({:other => {}}.deep_merge(data))
  end
  
  def method_missing(method, *args, &block)
    if method[-1] == "="
      raise 'setters not supported for other/dynamic/extra data attributes'
    else
      methodized_other.send(method, *args)
    end
  end

  def update(data)
    # fixed_attributes = data.extract!(self.attributes.keys)
    # fixed_attributes.each do |name, value|
    #   self.send("#{name}=", value)
    # end
    self.other = (self.other || {}).deep_merge(data)
    self.save
  end

  private

  def after_save
    reset_other
  end
  
  def reset_other
    @methodized_other = nil
  end
  
  def methodized_other
    @methodized_other ||= Hashie::Mash.new(self.other)
  end
  
end
