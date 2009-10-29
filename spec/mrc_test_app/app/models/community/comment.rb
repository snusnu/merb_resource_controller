module Community

  class Comment
  
    include DataMapper::Resource
  
    property :id,   Serial
    property :body, String,  :nullable => false, :length => (3..255)
  
    belongs_to :article
    has n, :ratings, "Community::Rating"
    
    def article_title
      article.title
    end
  
  end

end