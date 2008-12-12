require File.dirname(__FILE__) + '/../spec_helper'

describe "GET" do
  
  describe "resource(:articles)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(:articles))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :index template" do
      @response.should have_selector("tr:nth-child(2)")
      @response.should have_selector("td:nth-child(1):contains('article title')")
      @response.should have_selector("td:nth-child(2):contains('Anonymous')")
      @response.should have_selector("td:nth-child(3):contains('article body')")
    end

  end
  
  describe "resource(:articles, :new)" do

    before(:each) do
      @response = request(resource(:articles, :new))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :new template" do
      @response.should have_selector("h2:contains('New Article')")
    end

  end
  
  describe "resource(@article)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(Article.first))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :show template" do
      @response.should have_selector("h2:contains('Show Article')")
      @response.should have_selector("h3:contains('article title')")
      @response.should have_selector("p:contains('article body')")
    end
    
  end

  describe "resource(@article, :edit)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(Article.first, :edit))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Article')")
    end

  end
  
end


describe "POST resource(:articles)" do
  
  describe "Success" do
    
    before(:each) do
      Article.all.destroy!
      @response = request(
        resource(:articles), 
        :method => "POST", 
        :params => { 
          :article => { 
            :id => nil, 
            :title => "article title", 
            :body => "article body"
          }
        }
      )
    end
    
    it "should redirect to resource(@article)" do
      @response.should redirect_to(
        resource(Article.first), 
        :message => {
          :notice => "Article was successfully created"
        }
      )
    end
    
  end
    
  describe "Failure" do
    
    before(:each) do
      Article.all.destroy!
      @response = request(
        resource(:articles), 
        :method => "POST", 
        :params => { 
          :article => { 
            :id => nil,
            :title => nil,
            :body => "article body" 
          }
        }
      )
    end
    
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :new action" do
      @response.should have_selector("h2:contains('New Article')")
    end
    
  end
  
end

describe "PUT resource(@article)", :given => "an Article exists" do
  
  describe "Success" do
    
    before(:each) do
      @article = Article.first
      @response = request(
        resource(@article), 
        :method => "PUT", 
        :params => { :article => { :id => @article.id, :title => "updated title", :body => "updated body" } }
      )
    end
  
    it "should redirect to resource(@article)" do
      @response.should redirect_to(resource(@article))
    end
    
  end
  
  describe "Failure" do
  
    before(:each) do
      @article = Article.first
      @response = request(
        resource(@article), 
        :method => "PUT", 
        :params => { :article => { :id => @article.id, :title => nil, :body => "updated body" } }
      )
    end
  
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Article')")
    end
  
  end
  
end

describe "DELETE resource(@article)" do
  
  describe "Success", :given => "an Article exists" do
    
    before(:each) do
      @response = request(resource(Article.first), :method => "DELETE")
    end

    it "should redirect to resource(:articles)" do
      @response.should redirect_to(resource(:articles))
    end

  end
    
  describe "Failure" do
    
    before(:each) do
      Article.all.destroy!
      @response = request('/articles/1', :method => "DELETE")
    end

    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 404
    end

  end
  
end
