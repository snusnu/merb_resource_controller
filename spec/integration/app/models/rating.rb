module Community

  class Rating
  
    include DataMapper::Resource
  
    property :id,         Serial
    property :comment_id, Integer
    property :rate,       Integer
  
    belongs_to :comment
  
  end

end