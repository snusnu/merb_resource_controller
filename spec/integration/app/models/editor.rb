class Editor
  
  include DataMapper::Resource
  
  property :id, Serial
  
  property :name, String
  
  has n, :articles
  
end