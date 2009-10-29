class Article
  
  include DataMapper::Resource
  
  property :id,      Serial
  property :title,   String, :nullable => false, :length => (3..80)
  property :body,    String
  
  belongs_to :editor, :nullable => true
  
  has n, :comments, "Community::Comment"
  
  def editor_name
    editor ? editor.name : "Anonymous"
  end
  
end