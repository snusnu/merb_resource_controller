require File.dirname(__FILE__) + '/spec_helper'

given "an Article exists" do
  Article.all.destroy!
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :title => "yo", :body => "snusnu" }}
  )
end

given "an Editor exists" do
  Article.all.destroy!
  Editor.all.destroy!
  
  Editor.create({ :id => nil, :name => "snusnu" })
  
  request(
    resource(:articles), 
    :method => "POST", 
    :params => { :article => { :id => nil, :editor_id => Editor.first.id, :title => "yo", :body => "snusnu" }}
  )
end


describe "resource(:article_editor)" do
  
  describe "GET", :given => "an Editor exists" do
    
    before(:each) do
      @response = request(resource(Article.first, :editor))
    end
    
    it "should respond successfully" do
      @response.should be_successful
    end
    
  end
  
  describe "a successful POST", :given => "an Article exists" do
    
    before(:each) do
      Editor.all.destroy!
      @response = request(resource(Article.first, :editor), 
        :method => "POST", 
        :params => { :editor => { :id => nil, :name => "snusnu" }}
        )
    end
    
    it "should redirect to resource(@article, :editor)" do
      @response.should redirect_to(resource(Article.first, :editor), :message => {:notice => "Comment was successfully created"})
    end
    
  end
  
end

describe "resource(@article, @editor)" do 
  
  describe "a successful DELETE", :given => "an Editor exists" do
    
     before(:each) do
       @response = request(resource(Article.first, :editor), :method => "DELETE")
     end

     it "should redirect to resource(@article)" do
       @response.should redirect_to(resource(Article.first))
     end

   end
   
end

describe "resource(@article, :editor, :new)", :given => "an Article exists" do
  
  before(:each) do
    @response = request(resource(Article.first, :editor, :new))
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

describe "resource(@article, :editor)", :given => "an Editor exists" do
  
  describe "PUT" do
    
    before(:each) do
      @response = request(resource(Article.first, :editor), :method => "PUT", 
        :params => { :editor => {:id => Editor.first.id, :name => "bender" } })
    end
  
    it "should redirect to resource(@article, :editor)" do
      @response.should redirect_to(resource(Article.first, :editor))
    end
    
  end
  
end
