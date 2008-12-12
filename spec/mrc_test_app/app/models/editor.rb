class Editor
  
  include DataMapper::Resource
  
  property :id, Serial
  
  property :name, String, :nullable => false, :length => (3..40)
  
  has n, :articles
  
end