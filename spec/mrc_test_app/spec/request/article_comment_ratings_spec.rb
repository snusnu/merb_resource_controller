require File.dirname(__FILE__) + '/../spec_helper'

describe "GET" do
  
  describe "resource(@article, @comment, :ratings)", :given => "3 Ratings exist" do
    
    it "should respond successfully" do
      request(resource(Article.first, Community::Comment.first, :ratings)).should be_successful
    end
    
    it "should render the :index template" do
      @response = request(resource(Article.get(1), Community::Comment.get(1), :ratings))
      @response.should have_selector("tr:eq(2) td:nth-child(1):contains('1')")
      @response.should have_selector("tr:eq(2) td:nth-child(2):contains('comment body')")
      @response.should have_selector("tr:eq(2) td:nth-child(3):contains('1')")
      @response.should have_selector("tr:eq(3) td:nth-child(1):contains('2')")
      @response.should have_selector("tr:eq(3) td:nth-child(2):contains('comment body')")
      @response.should have_selector("tr:eq(3) td:nth-child(3):contains('1')")
      @response.should_not have_selector("tr:eq(4)")
      
      @response = request(resource(Article.get(1), Community::Comment.get(2), :ratings))
      @response.should have_selector("tr:eq(2) td:nth-child(1):contains('3')")
      @response.should have_selector("tr:eq(2) td:nth-child(2):contains('comment body')")
      @response.should have_selector("tr:eq(2) td:nth-child(3):contains('1')")
      @response.should_not have_selector("tr:eq(3)")
    end
    
  end
  
  describe "resource(@article, @comment, :ratings, :new)", :given => "a Comment exists" do

    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, :ratings, :new))
    end

    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :new template" do
      @response.should have_selector("h2:contains('New Rating')")
    end

  end
  
  describe "resource(@article, @comment, @rating)", :given => "a Rating exists" do

    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, Community::Rating.first))
    end

    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :show template" do
      @response.should have_selector("h2:contains('Show Rating')")
    end
    
  end

  describe "resource(@article, @comment, @rating, :edit)", :given => "a Rating exists" do

    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, Community::Rating.first, :edit))
    end

    it "should respond successfully" do
      @response.should be_successful
    end
    
    it "should render the :edit template" do
      @response.should have_selector("h2:contains('Edit Rating')")
    end

  end
  
end

describe "POST resource(@article, @comment, :ratings)" do
  
  describe "Success", :given => "a Comment exists" do
    
    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, :ratings), 
        :method => "POST", 
        :params => { :rating => { :id => nil, :rate => 1 }}
        )
    end
    
    it "should redirect to resource(@article, @comment, @rating)" do
      @response.should redirect_to(
        resource(Article.first, Community::Comment.first, Community::Rating.first), 
        :message => {:notice => "Rating was successfully created"}
      )
    end
    
  end
    
  describe "Failure", :given => "a Comment exists" do
    
    before(:each) do
      @response = request(resource(Article.first, Community::Comment.first, :ratings), 
        :method => "POST", 
        :params => { :rating => { :id => nil, :rate => nil }}
        )
    end
    
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :new action" do
      @response.should have_selector("h2:contains('New Rating')")
    end
    
  end
  
end

describe "PUT resource(@article, @comment, @rating)", :given => "a Rating exists" do
  
  describe "Success" do
    
    before(:each) do
      @article = Article.first
      @comment = Community::Comment.first
      @rating  = Community::Rating.first
      @response = request(resource(@article, @comment, @rating), :method => "PUT", 
        :params => { :rating => { :id => @rating.id, :rate => 5 } })
    end
  
    it "should redirect to resource(@article, @comment, @rating)" do
      @response.should redirect_to(resource(@article, @comment, @rating))
    end
    
  end
    
  describe "Failure" do
    
    before(:each) do
      @article = Article.first
      @comment = Community::Comment.first
      @rating  = Community::Rating.first
      @response = request(resource(@article, @comment, @rating), :method => "PUT", 
        :params => { :rating => { :id => @rating.id, :rate => nil } })
    end
  
    it "should not be successful" do
      @response.should_not be_successful
      @response.status.should == 406
    end
    
    it "should render the :edit template" do
       @response.should have_selector("h2:contains('Edit Rating')")
    end
    
  end
   
end

describe "DELETE resource(@article, @comment, @rating)" do 
  
  describe "Success", :given => "a Rating exists" do
    
     before(:each) do
       @response = request(
        resource(Article.first, Community::Comment.first, Community::Rating.first),
        :method => "DELETE"
      )
     end

     it "should redirect to resource(@article, :comments)" do
       @response.should redirect_to(resource(Article.first, Community::Comment.first, :ratings))
     end

   end
   
   describe "Failure" do

      before(:each) do
        @response = request(
         "/articles/#{Article.first.id}/comments/#{Community::Comment.first.id}/ratings/1",
         :method => "DELETE"
       )
      end

      it "should not be successful" do
        @response.should_not be_successful
        @response.status.should == 404
      end

    end
   
end
