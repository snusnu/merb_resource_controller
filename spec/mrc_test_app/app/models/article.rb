class Article
  
  include DataMapper::Resource
  
  property :id,      Serial
  property :title,   String, :nullable => false, :length => (3..80)
  property :body,    String
  
  property :editor_id, Integer
  
  belongs_to :editor
  
  has n, :comments, :class_name => "Community::Comment"
  
  def editor_name
    editor ? editor.name : "Anonymous"
  end
  
end