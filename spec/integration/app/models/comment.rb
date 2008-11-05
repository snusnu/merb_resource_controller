class Comment
  
  include DataMapper::Resource
  
  property :id,         Serial
  
  property :article_id, Integer
  
  property :body,       String
  
end