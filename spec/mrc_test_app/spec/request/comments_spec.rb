require File.dirname(__FILE__) + '/../spec_helper'

describe "GET" do
  
  describe "resource(:comments)", :given => "a Comment exists" do
    
    before(:each) do
      @response = request(resource(:comments))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :index template" do
      @response.should have_selector("tr:eq(2) td:nth-child(1):contains('1')")
      @response.should have_selector("tr:eq(2) td:nth-child(2):contains('article title')")
      @response.should have_selector("tr:eq(2) td:nth-child(3):contains('comment body')")
      @response.should_not have_selector("tr:eq(3)")
    end
    
  end
  
  describe "resource(:comments, :new)" do

    before(:each) do
      @response = request(resource(:comments, :new))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :new template" do
      @response.should have_selector("h2:contains('New Comment')")
    end

  end
  
  describe "resource(@comment)", :given => "a Comment exists" do

    before(:each) do
      @response = request(resource(Community::Comment.first))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :show template" do
      @response.should have_selector("h2:contains('Show Comment')")
      @response.should have_selector("p:contains('comment body')")
    end
    
  end
  
  describe "resource(@comment, :edit)", :given => "a Comment exists" do

    before(:each) do
      @response = request(resource(Community::Comment.first, :edit))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :show template" do
      @response.should have_selector("h2:contains('Edit Comment')")
    end

  end
  
end

describe "POST resource(:comments)" do
  
  describe "Success", :given => "an Article exists" do
    
    before(:each) do
      Community::Comment.all.destroy!
      @response = request(resource(:comments), 
        :method => "POST", 
        :params => { 
          :comment => { 
            :id => nil, 
            :article_id => Article.first.id, 
            :body => "comment body"
          }
        }
      )
    end
    
    it "should redirect to resource(@comment)" do
      @response.should redirect_to(
        resource(Community::Comment.first), 
        :message => {
          :notice => "Comment was successfully created"
        }
      )
    end
    
  end
    
  describe "Failure", :given => "an Article exists" do
    
    before(:each) do
      Community::Comment.all.destroy!
      @response = request(
        resource(:comments), 
        :method => "POST", 
        :params => { 
          :comment => { 
            :id => nil, 
            :article_id => nil, 
            :body => "comment body"
          }
        }
      )
    end
    
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :new action" do
      @response.should have_selector("h2:contains('New Comment')")
    end
    
  end
  
end

describe "PUT resource(@comment)", :given => "a Comment exists" do
  
  describe "Success" do
    
    before(:each) do
      @comment = Community::Comment.first
      @response = request(
        resource(@comment), 
        :method => "PUT", 
        :params => { 
          :comment => {
            :id => @comment.id, 
            :body => "updated comment body"
          }
        }
      )
    end
  
    it "should redirect to resource(@comment)" do
      @response.should redirect_to(resource(@comment))
    end
    
  end
  
  describe "Failure" do
  
    before(:each) do
      @comment = Community::Comment.first
      @response = request(
        resource(@comment), 
        :method => "PUT", 
        :params => { 
          :comment => { 
            :id => @comment.id,
            :article_id => nil,
            :body => "updated comment body"
          }
        }
      )
    end
  
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :edit template" do
      @response.should have_selector("form[action='/comments/1'][method='post']")
      @response.should have_selector("input[id='community::comment_body'][name='community::comment[body]'][type='text']")
      @response.should have_selector("input[type='hidden'][value='put'][name='_method']")
    end
  
  end
  
end

describe "DELETE resource(@comment)" do
  
  describe "Success", :given => "a Comment exists" do
    
    before(:each) do
      @response = request(
        resource(Community::Comment.first), 
        :method => "DELETE"
      )
    end

    it "should redirect to resource(:comments)" do
      @response.should redirect_to(resource(:comments))
    end

  end
  
  describe "Failure" do
    
    before(:each) do
      Community::Comment.all.destroy!
      @response = request('/comments/1', :method => "DELETE")
    end

    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 404
    end

  end
  
end