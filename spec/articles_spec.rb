require File.dirname(__FILE__) + '/spec_helper'

given "an Article exists" do
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
end

describe "resource(:articles)" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:articles))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "a successful POST" do
    
    before(:each) do
      Article.all.destroy!
      @response = request(resource(:articles), 
        :method => "POST", 
        :params => { :article => { :id => nil, :title => "Hey there", :body => "Me like snusnu" }}
        )
    end
    
    it "should redirect to resource(@article)" do
      @response.should redirect_to(resource(Article.first), :message => {:notice => "Article was successfully created"})
    end
    
  end
  
end

describe "resource(@article)" do 
  
  describe "a successful DELETE", :given => "an Article exists" do
    
     before(:each) do
       @response = request(resource(Article.first), :method => "DELETE")
     end

     it "should redirect to resource(:articles)" do
       @response.should redirect_to(resource(:articles))
     end

   end
   
end

describe "resource(:articles, :new)" do
  
  describe "GET" do
  
    before(:each) do
      @response = request(resource(:articles, :new))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
  
  end
  
end

describe "resource(@article, :edit)", :given => "an Article exists" do
  
  describe "PUT" do
  
    before(:each) do
      @response = request(resource(Article.first, :edit))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
  
  end
  
end

describe "resource(@article)", :given => "an Article exists" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Article.first))
    end
  
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "PUT" do
    
    before(:each) do
      @article = Article.first
      @response = request(resource(@article), :method => "PUT", 
        :params => { :article => {:id => @article.id} })
    end
  
    it "should redirect to resource(@article)" do
      @response.should redirect_to(resource(@article))
    end
    
  end
  
end
