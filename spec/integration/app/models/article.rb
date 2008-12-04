class Article
  
  include DataMapper::Resource
  
  property :id,      Serial
  property :title,   String
  property :body,    String
  
  property :editor_id, Integer
  
  belongs_to :editor
  
  has n, :comments, :class_name => "Community::Comment"
  
end