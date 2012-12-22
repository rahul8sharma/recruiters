class Recruiters::Job < Ohm::Model

  include Ohm::DataTypes
  include Ohm::Timestamps
  include Ohm::Callbacks
  
  attribute :other, Type::Hash

  FIXED_ATTRIBUTES = [
    [:status, Type::Integer],
    [:posted_by, Type::Integer],
    [:uuid]
  ]

  UNIQUE_ATTRIBUTES = [:uuid]
  
  FIXED_ATTRIBUTES.each do |name, type|
    type ? attribute(name, type) : attribute(name)
    index(name)
  end

  UNIQUE_ATTRIBUTES.each { |attr| unique attr }

  module STATUSES
    INCOMPLETE, PENDING, READY, OPEN, CLOSED = (1..5).to_a
  end
  
  def self.create(data={})
    self.new.update(data.deep_merge(self.default_state))
  end

  def duplicate
    attribs = self.attributes
    
    copy_attrib_names = [:posted_by]
    copy_attribs = attribs.extract!(*copy_attrib_names)

    ap copy_attribs
    merged_attribs = (self.other || {}).deep_merge(copy_attribs)

    self.class.create(merged_attribs)
  end

  def update(data)
    fixed_attributes = data.extract!(*FIXED_ATTRIBUTES.map(&:first))
    fixed_attributes.select{|_, v| v}.each do |name, value|
      self.send("#{name}=", value)
    end
    self.other = (self.other || {}).deep_merge(data)
    self.save
    self
  end

  def repost
    leo_job = Vger::Spartan::Opus::Recommendation.find(self.leonidas_id)
    leo_job.update_attributes(:updated_at => Time.now,
                              :bucket_attributes => {
                                :posted_on => Time.now
                              })
  end

  def open
    leo_job = Vger::Spartan::Opus::Recommendation.find(self.leonidas_id)
    leo_job.update_attributes(:active => true)
  end

  def close
    leo_job = Vger::Spartan::Opus::Recommendation.find(self.leonidas_id)
    leo_job.update_attributes(:active => false)
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

  def self.default_state
    {
      :uuid => SecureRandom.hex(3),
      :status => STATUSES::INCOMPLETE
    }
  end

  def set_default_state
    update(self.class.default_state)
  end

  def method_missing(method, *args, &block)
    if method[-1] == "="
      raise "setter(#{method}) not supported for other/dynamic/extra data attribute"
    else
      methodized_other.send(method, *args)
    end
  end
end
