require File.dirname(__FILE__) + '/spec_helper'

given "an Article exists" do
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
end

given "a Comment exists" do
  Community::Comment.all.destroy!
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
  request(
    resource(:comments), 
    :method => "POST", 
    :params => { :comment => { :id => nil, :article_id => Article.first.id, :body => "yeah" }}
  )
end

describe "resource(:comments)" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:comments))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "a successful POST", :given => "an Article exists" do
    
    before(:each) do
      Community::Comment.all.destroy!
      @response = request(resource(:comments), 
        :method => "POST", 
        :params => { :comment => { :id => nil, :article_id => Article.first, :body => "yeah" }}
        )
    end
    
    it "should redirect to resource(@comment)" do
      @response.should redirect_to(resource(Community::Comment.first), :message => {:notice => "Comment was successfully created"})
    end
    
  end
  
end

describe "resource(@comment)" do 
  
  describe "a successful DELETE", :given => "a Comment exists" do
    
     before(:each) do
       @response = request(resource(Community::Comment.first), :method => "DELETE")
     end

     it "should redirect to resource(:comments)" do
       @response.should redirect_to(resource(:comments))
     end

   end
   
end

describe "resource(:comments, :new)" do
  
  describe "GET" do
  
    before(:each) do
      @response = request(resource(:comments, :new))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
  
  end
  
end

describe "resource(@comment, :edit)", :given => "a Comment exists" do
  
  describe "PUT" do
  
    before(:each) do
      @response = request(resource(Community::Comment.first, :edit))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
  
  end
  
end

describe "resource(@comment)", :given => "a Comment exists" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Community::Comment.first))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "PUT" do
    
    before(:each) do
      @comment = Community::Comment.first
      @response = request(resource(@comment), :method => "PUT", 
        :params => { :comment => {:id => @comment.id, :body => "changed" } })
    end
  
    it "should redirect to resource(@comment)" do
      @response.should redirect_to(resource(@comment))
    end
    
  end
  
end
