require File.dirname(__FILE__) + '/spec_helper'

given "a Comment exists" do
  Community::Rating.all.destroy!
  Community::Comment.all.destroy!
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
  request(
    resource(Article.first, :comments), 
    :method => "POST", 
    :params => { :comment => { :id => nil, :article_id => Article.first.id, :body => "wassup" } }
  )
end

given "a Rating exists" do
  Community::Rating.all.destroy!
  Community::Comment.all.destroy!
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
  request(
    resource(Article.first, :comments), 
    :method => "POST", 
    :params => { :comment => { :id => nil, :article_id => Article.first.id, :body => "wassup" } }
  )
  request(
    resource(Article.first, Community::Comment.first, :ratings), 
    :method => "POST", 
    :params => { :rating => { :id => nil, :comment_id => Community::Comment.first.id, :rate => 1 } }
  )
end


describe "resource(@article, @comment, :ratings)" do
  
  describe "GET", :given => "a Rating exists" do
    
    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, :ratings))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "a successful POST", :given => "a Comment exists" do
    
    before(:each) do
      Community::Rating.all.destroy!
      @response = request(resource(Article.first, Community::Comment.first, :ratings), 
        :method => "POST", 
        :params => { :rating => { :id => nil, :comment_id => Community::Comment.first.id, :rate => 1 }}
        )
    end
    
    it "should redirect to resource(@article, @comment, @rating)" do
      @response.should redirect_to(
        resource(Article.first, Community::Comment.first, Community::Rating.first), 
        :message => {:notice => "Rating was successfully created"}
      )
    end
    
  end
  
end

describe "resource(@article, @comment, @rating)" do 
  
  describe "a successful DELETE", :given => "a Rating exists" do
    
     before(:each) do
       @response = request(resource(Article.first, Community::Comment.first, Community::Rating.first), :method => "DELETE")
     end

     it "should redirect to resource(@article, :comments)" do
       @response.should redirect_to(resource(Article.first, Community::Comment.first, :ratings))
     end

   end
   
end

describe "resource(@article, @comment, :ratings, :new)", :given => "a Comment exists" do
  
  before(:each) do
    @response = request(resource(Article.first, Community::Comment.first, :ratings, :new))
  end
  
  it "should respond successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article, @comment, @rating, :edit)", :given => "a Rating exists" do
  
  before(:each) do
    @response = request(resource(Article.first, Community::Comment.first, Community::Rating.first, :edit))
  end
  
  it "should respond successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article, @comment, @rating)", :given => "a Rating exists" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, Community::Rating.first))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "PUT" do
    
    before(:each) do
      @article = Article.first
      @comment = Community::Comment.first
      @rating  = Community::Rating.first
      @response = request(resource(@article, @comment, @rating), :method => "PUT", 
        :params => { :rating => { :id => @rating.id } })
    end
  
    it "should redirect to resource(@article, @comment, @rating)" do
      @response.should redirect_to(resource(@article, @comment, @rating))
    end
    
  end
   
end
