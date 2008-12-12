require File.dirname(__FILE__) + '/../spec_helper'

describe "GET" do

  describe "resource(@article, :editors)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(Article.first, :editor, :new))
    end

    it "should not respond to the :index action" do
      lambda { 
        request(resource(Article.first, :editors))
      }.should raise_error(Merb::Router::GenerationError)
    end

  end
    
  describe "resource(@article, :editor, :new)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(Article.first, :editor, :new))
    end

    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :new template" do
      @response.should have_selector("h2:contains('New Editor')")
    end

  end
  
  describe "resource(@article, :editor)", :given => "an Editor exists" do
    
    before(:each) do
      @response = request(resource(Article.first, :editor))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "resource(@article, :editor, :edit)", :given => "an Editor exists" do

    before(:each) do
      @response = request(resource(Article.first, :editor, :edit))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

  end
  
end

describe "POST resource(@article, :editor)" do
  
  describe "Success", :given => "an Article exists" do
    
    before(:each) do
      Editor.all.destroy!
      @response = request(
        resource(Article.first, :editor), 
        :method => "POST", 
        :params => {
          :editor => { 
            :id => nil, 
            :name => "snusnu"
          }
        }
      )
    end
    
    it "should redirect to resource(@article, :editor)" do
      @response.should redirect_to(
        resource(Article.first, :editor), 
        :message => {
          :notice => "Editor was successfully created"
        }
      )
    end
    
  end
    
  describe "Failure", :given => "an Article exists" do
    
    before(:each) do
      Editor.all.destroy!
      @response = request(resource(Article.first, :editor), 
        :method => "POST", 
        :params => {
          :editor => { 
            :id => nil, 
            :name => nil
          }
        }
      )
    end
    
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :new action" do
      @response.should have_selector("h2:contains('New Editor')")
    end
    
  end
  
end

describe "PUT resource(@article, :editor)", :given => "an Editor exists" do
  
  describe "Success" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :editor), 
        :method => "PUT", 
        :params => { 
          :editor => {
            :id => Editor.first.id, 
            :name => "bender"
          }
        }
      )
    end
  
    it "should redirect to resource(@article, :editor)" do
      @response.should redirect_to(resource(Article.first, :editor))
    end
    
  end
    
  describe "Failure" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :editor), 
        :method => "PUT", 
        :params => { 
          :editor => {
            :id => Editor.first.id, 
            :name => nil
          }
        }
      )
    end
  
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Editor')")
    end
    
  end
  
end

describe "DELETE resource(@article, @editor)" do 
  
  describe "Success", :given => "an Editor exists" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :editor), 
        :method => "DELETE"
      )
    end

    it "should redirect to resource(@article)" do
      @response.should redirect_to(resource(Article.first))
    end

  end
     
  describe "Failure", :given => "an Article exists" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :editor), 
        :method => "DELETE"
      )
    end

    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 404
    end

  end
   
end