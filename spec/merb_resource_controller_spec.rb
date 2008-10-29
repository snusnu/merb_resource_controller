require File.dirname(__FILE__) + '/spec_helper'

given "an article exists" do
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
    
    it "responds successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "GET", :given => "an article exists" do
    
    before(:each) do
      @response = request(resource(:articles))
    end
    
    it "has a list of articles" do
      pending
      @response.should have_xpath("//ul/li")
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
    
    it "redirects to resource(:articles)" do
      Article.first.should_not be_nil
      @response.should redirect_to(resource(Article.first), :message => {:notice => "Article was successfully created"})
    end
    
  end
  
end

describe "resource(@article)" do 
  
  describe "a successful DELETE", :given => "an article exists" do
    
     before(:each) do
       Merb.logger.info "ARTICLE: #{Article.first.inspect}"
       @response = request(resource(Article.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:articles))
     end

   end
   
end

describe "resource(:articles, :new)" do
  
  before(:each) do
    @response = request(resource(:articles, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article, :edit)", :given => "an article exists" do
  
  before(:each) do
    @response = request(resource(Article.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
  
end

describe "resource(@article)", :given => "an article exists" do
  
  describe "GET" do
    
    before(:each) do
      @response = request(resource(Article.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "PUT" do
    
    before(:each) do
      @article = Article.first
      @response = request(resource(@article), :method => "PUT", 
        :params => { :article => {:id => @article.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@article))
    end
    
  end
  
end
