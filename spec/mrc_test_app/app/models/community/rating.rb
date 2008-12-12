module Community

  class Rating
  
    include DataMapper::Resource
  
    property :id,         Serial
    property :comment_id, Integer, :nullable => false
    property :rate,       Integer, :nullable => false
  
    belongs_to :comment
    
    def comment_body
      comment.body
    end
  
  end

end