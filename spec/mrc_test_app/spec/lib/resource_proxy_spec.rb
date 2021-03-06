require File.dirname(__FILE__) + '/../spec_helper'

describe "Merb::ResourceController::ResourceProxy" do
  
  describe "every ResourceProxy", :shared => true do
    
    it "should be able to load not namespaced models" do
      @p.send(:load_resource, Article).should  == Article
      @p.send(:load_resource, :articles).should == Article
      @p.send(:load_resource, "Article").should == Article
    end
    
  end
  
  describe "every nested resource", :shared => true do
    
    it "should know that it has parent resource" do
      @p.has_parent?.should be_true
    end
    
  end
    
  describe "every toplevel resource", :shared => true do
    
    it "should know that it has no parent resource(s)" do
      @p.has_parent?.should be_false
    end
    
  end
  
  describe "with default options" do
    
    before(:each) do
      options = { :defaults => true, :use => :all }
      @p = Merb::ResourceController::ResourceProxy.new(:articles, options)
    end
    
    it_should_behave_like "every ResourceProxy"
    it_should_behave_like "every toplevel resource"
    

    it "should be able to load the resource it proxies" do
      @p.resource.should == Article
    end
    
    it "should be able to infer the collection_name for the resource it proxies" do
      @p.collection_name.should == :articles
    end
        
    it "should be able to infer the member_name for the resource it proxies" do
      @p.member_name.should == :article
    end
    
    it "should have the default actions registered" do
      default_actions = [ :index, :show, :new, :edit, :create, :update, :destroy ]
      actions = @p.registered_actions.map { |ad| ad.action_name }
      
      actions.size.should == default_actions.size
      actions.all? { |a| default_actions.include?(a) }.should be_true
    end
    
    
    it "should have no specific methods registered" do
      @p.specific_methods_registered?.should be_false
    end
            
    it "should have no parents" do
      @p.parents.should be_empty
    end
        
    it "should have no parent_keys" do
      @p.parent_keys.should be_empty
    end
    
  end
  
  describe "with invalid (parent) resource" do

    it "should raise NameError when initialized with an invalid resource" do
      options = { :defaults => true, :use => :all }
      lambda {
        Merb::ResourceController::ResourceProxy.new(:foo, options)
      }.should raise_error(NameError)
    end
    
    it "should raise NameError when it should belong to an invalid parent resource" do
      options = { :defaults => true, :use => :all }
      lambda {
        p = Merb::ResourceController::ResourceProxy.new("Community::Comment", options)
        p.belongs_to :foo
      }.should raise_error(NameError)
    end
    
  end


  describe "with no parent resource" do
    
    before(:each) do
      options = { :defaults => true, :use => :all }
      @p = Merb::ResourceController::ResourceProxy.new(:articles, options)
    end
    
    it_should_behave_like "every toplevel resource"
        
    it "should return an empty array for parent_resources" do
      @p.parent_resources.should == []
    end
            
    it "should return nil for parent_resource" do
      @p.parent_resource.should be_nil
    end
    
                
    it "should return an empty array for parent_keys" do
      @p.parent_keys.should == []
    end
                    
    it "should return nil for parent_key" do
      @p.parent_key.should be_nil
    end
    
    
    
    it "should return an array with one member for nesting strategy" do
      @p.nesting_strategy.should == [ [Article, false, false] ]
    end

    it "should know its nesting_level" do
      @p.nesting_level.should == 1
    end

    it "should be able to build a nesting strategy template for a collection route" do
      params = {}
      @p.nesting_strategy_template(params).should == [ [Article, false, false, nil] ]
    end
    
    it "should be able to build a nesting strategy template for a member route" do
      params = { "id" => 1}
      @p.nesting_strategy_template(params).should == [ [Article, false, false, 1] ]
    end
    
  end
    
    
  describe "with a single parent resource" do
    
    before(:each) do
      options = { :defaults => true, :use => :all }
      @p = Merb::ResourceController::ResourceProxy.new("Community::Comment", options)
      @p.belongs_to :article
    end
    
    it_should_behave_like "every nested resource"
    
    
    it "should know that it belongs_to? a single parent resource" do
      @p.belongs_to?(:article).should be_true
    end
        
    it "should be able to load all parent resources" do
      @p.parent_resources.should == [ [Article, false, false] ]
    end
            
    it "should be able to load a single parent resource" do
      @p.parent_resource.should == [ Article, false, false ]
    end
    
                
    it "should be able to return all parent resource param keys" do
      @p.parent_keys.should == [ "article_id" ]
    end
                    
    it "should be able to return its immediate parent resource param key" do
      @p.parent_key.should == "article_id"
    end
                        
    it "should be able to build member_params from params Hash" do
      params = { :article_id => 1, :comment => { :id => 1, :body => "foo" } }
      @p.member_params(params).should == { :id => 1, :article_id => 1, :body => "foo" }
      
      params = { :article_id => 1, :comment => { :id => 1, :article_id => 2, :body => "foo" } }
      @p.member_params(params).should == { :id => 1, :article_id => 2, :body => "foo" }
    end
    
    
    
    it "should be able to build a nesting strategy" do
      @p.nesting_strategy.should == [ [Article, false, false], [Community::Comment, false, false] ]
    end

    it "should know its nesting_level" do
      @p.nesting_level.should == 2
    end

    it "should be able to build a nesting strategy template for a collection route" do
      params = { "article_id" => 1 }
      @p.nesting_strategy_template(params).should == [ [Article, false, false, 1], [Community::Comment, false, false, nil] ]
    end
    
    it "should be able to build a nesting strategy template for a member route" do
      params = { "article_id" => 1, "id" => 1}
      @p.nesting_strategy_template(params).should == [ [Article, false, false, 1], [Community::Comment, false, false, 1] ]
    end
    
  end
      
  describe "with multiple parent resources with default keys" do
    
    before(:each) do
      options = { :defaults => true, :use => :all }
      @p = Merb::ResourceController::ResourceProxy.new("Community::Rating", options)
      @p.belongs_to [ :article, "Community::Comment" ]
    end
    
    it_should_behave_like "every nested resource"
    
    
    it "should know that it belongs_to? all of its parent resources" do
      @p.belongs_to?(:article).should be_true
      @p.belongs_to?("Community::Comment").should be_true
    end
    
    it "should be able to load the immediate parent resource" do
      @p.parent_resource.should == [ Community::Comment, false, false ]
    end
     
    it "should be able to load all parent resources" do
      @p.parent_resources.should == [ [Article, false, false], [Community::Comment, false, false] ]
    end
    
    it "should be able to return all parent resource param keys" do
      @p.parent_keys.should == [ "article_id", "comment_id" ]
    end
        
    it "should be able to return all parent params" do
      params = { "article_id" => 1, "comment_id" => 2}
      @p.parent_param_values(params).should == [ 1, 2 ]
    end

    it "should be able to return its immediate parent resource param key" do
      @p.parent_key.should == "comment_id"
    end
    
    
    it "should know its nesting_level" do
      @p.nesting_level.should == 3
    end
         
    it "should be able to build a nesting strategy" do
      @p.nesting_strategy.should == [ [Article, false, false], [Community::Comment, false, false], [Community::Rating, false, false] ]
    end
    
    
    it "should be able to build a nesting strategy template for a collection route" do
      params = { "article_id" => 1, "comment_id" => 1 }
      @p.nesting_strategy_template(params).should == [ [Article, false, false, 1], [Community::Comment, false, false, 1], [Community::Rating, false, false, nil] ]
    end
    
    it "should be able to build a nesting strategy instance for a collection route" do
      Article.all.destroy!
      Community::Comment.all.destroy!
      Community::Rating.all.destroy!
      a = Article.create(:id => 1, :title => "title", :body => "body")
      c = Community::Comment.create(:id => 1, :article_id => 1, :body => "say what")
      r = Community::Rating.create(:id => 1, :comment_id => 1, :rate => 1)
      
      params = { "article_id" => 1, "comment_id" => 1 }
      @p.path_to_resource(params).should == [ [:article,a], [:comment,c], [:ratings, [r]] ]
    end
    
             
    it "should be able to build a nesting strategy template for a member route" do
      params = { "article_id" => 1, "comment_id" => 1, "id" => 1 }
      @p.nesting_strategy_template(params).should == [ [Article, false, false, 1], [Community::Comment, false, false, 1], [Community::Rating, false, false, 1] ]
    end
                 
    it "should be able to build a nesting strategy instance for a member route" do
      Article.all.destroy!
      Community::Comment.all.destroy!
      Community::Rating.all.destroy!
      a = Article.create(:id => 1, :title => "title", :body => "body")
      c = Community::Comment.create(:id => 1, :article_id => 1, :body => "say what")
      r = Community::Rating.create(:id => 1, :comment_id => 1, :rate => 1)
      
      params = { "article_id" => 1, "comment_id" => 1, "id" => 1}
      @p.path_to_resource(params).should == [ [:article,a], [:comment,c], [:rating, r] ]
    end
    
  end
  
end