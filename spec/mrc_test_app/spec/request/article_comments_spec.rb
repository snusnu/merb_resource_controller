require File.dirname(__FILE__) + '/../spec_helper'

describe "GET" do

  describe "resource(:article_comments)", :given => "2 articles and 3 comments exist" do
    
    it "should respond successfully" do
      request(resource(Article.first, :comments)).should be_successful
    end
    
    it "should render the :index template" do
      @response = request(resource(Article.get(1), :comments))
      @response.should have_selector("tr:eq(2) td:nth-child(1):contains('1')")
      @response.should have_selector("tr:eq(2) td:nth-child(2):contains('article title')")
      @response.should have_selector("tr:eq(2) td:nth-child(3):contains('comment body')")
      @response.should have_selector("tr:eq(3) td:nth-child(1):contains('2')")
      @response.should have_selector("tr:eq(3) td:nth-child(2):contains('article title')")
      @response.should have_selector("tr:eq(3) td:nth-child(3):contains('comment body')")
      @response.should_not have_selector("tr:eq(4)")
      
      @response = request(resource(Article.get(2), :comments))
      @response.should have_selector("tr:eq(2) td:nth-child(1):contains('3')")
      @response.should have_selector("tr:eq(2) td:nth-child(2):contains('article title')")
      @response.should have_selector("tr:eq(2) td:nth-child(3):contains('comment body')")
      @response.should_not have_selector("tr:eq(3)")
    end
    
  end
  
  describe "resource(@article, :comments, :new)", :given => "an Article exists" do

    before(:each) do
      @response = request(resource(Article.first, :comments, :new))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :new template" do
      @response.should have_selector("h2:contains('New Comment')")
    end

  end
  
  describe "resource(@article, @comment)", :given => "2 articles and 3 comments exist" do

    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first))
    end

    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :show template" do
      @response.should have_selector("h2:contains('Show Comment')")
    end
    
  end
  
  describe "resource(@article, @comment, :edit)", :given => "a Comment exists" do

    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, :edit))
    end

    it "should respond successfully" do
      @response.should be_successful
    end

    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Comment')")
    end

  end
  
end

describe "POST" do
  
  describe "Success", :given => "an Article exists" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :comments), 
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
    
    it "should redirect to resource(@article, @comment)" do
      @response.should redirect_to(
        resource(Article.first, Community::Comment.first), 
        :message => {
          :notice => "Comment was successfully created"
        }
      )
    end
    
  end
    
  describe "Failure", :given => "an Article exists" do
    
    before(:each) do
      @response = request(
        resource(Article.first, :comments), 
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

describe "PUT resource(@article, @comment)", :given => "2 articles and 3 comments exist" do
  
  describe "Success" do
    
    before(:each) do
      @article = Article.first
      @comment = Community::Comment.first
      @response = request(resource(@article, @comment), :method => "PUT", 
        :params => { :comment => {:id => @comment.id} })
    end
  
    it "should redirect to resource(@article, @comment)" do
      @response.should redirect_to(resource(@article, @comment))
    end
    
  end
  
  describe "Failure" do
    
    before(:each) do 
      @article = Article.first
      @comment = Community::Comment.first
      @response = request(resource(@article, @comment), :method => "PUT", 
        :params => { :comment => {:id => @comment.id, :body => nil } })
    end
  
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Comment')")
    end
    
  end
  
end

describe "DELETE resource(@article, @comment)" do
  
  describe "Success", :given => "a Comment exists" do
    
    before(:each) do
      @response = request(
        resource(Article.first, Community::Comment.first), 
        :method => "DELETE"
      )
    end

    it "should redirect to resource(@article, :comments)" do
      @response.should redirect_to(resource(Article.first, :comments))
    end

  end
   
  describe "Failure", :given => "an Article exists" do

    before(:each) do
      Community::Comment.all.destroy!
      @response = request("/articles/#{Article.first.id}/comments/1", :method => "DELETE")
    end

    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 404
    end

  end
  
end
