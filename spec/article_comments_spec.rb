require File.dirname(__FILE__) + '/spec_helper'

given "an Article exists" do
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
end

given "a Comment exists", :given => [ "an Article exists" ] do
  Comment.all.destroy!
  request(
    resource(Article.first, :comments), 
    :method => "POST", 
    :params => { :comment => { :id => nil, :body => "wassup" }}
  )
end


describe "resource(:article_comments)" do
  
  describe "GET", :given => "an Article exists" do
    
    before(:each) do
      @response = request(resource(Article.first, :comments))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "a successful POST", :given => "an Article exists" do
    
    before(:each) do
      Comment.all.destroy!
      @response = request(resource(Article.first, :comments), 
        :method => "POST", 
        :params => { :comment => { :id => nil, :body => "Me like snusnu" }}
        )
    end
    
    it "should redirect to resource(@article, @comment)" do
      @response.should redirect_to(resource(Article.first, Comment.first), :message => {:notice => "Comment was successfully created"})
    end
    
  end
  
end

describe "resource(@article, @comment)" do 
  
  describe "a successful DELETE", :given => "a Comment exists" do
    
     before(:each) do
       @response = request(resource(Article.first, Comment.first), :method => "DELETE")
     end

     it "should redirect to resource(@article, :comments)" do
       @response.should redirect_to(resource(Article.first, :comments))
     end

   end
   
end

describe "resource(@article, :comments, :new)", :given => "an Article exists" do
  
  before(:each) do
    @response = request(resource(Article.first, :comments, :new))
  end
  
  it "should respond successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article, @comment, :edit)", :given => "a Comment exists" do
  
  before(:each) do
    @response = request(resource(Article.first, Comment.first, :edit))
  end
  
  it "should respond successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article, @comment)", :given => "a Comment exists" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Article.first, Comment.first))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "PUT" do
    
    before(:each) do
      @article = Article.first
      @comment = Comment.first
      @response = request(resource(@article, @comment), :method => "PUT", 
        :params => { :comment => {:id => @comment.id} })
    end
  
    it "should redirect to resource(@article, @comment)" do
      @response.should redirect_to(resource(@article, @comment))
    end
    
  end
  
end
