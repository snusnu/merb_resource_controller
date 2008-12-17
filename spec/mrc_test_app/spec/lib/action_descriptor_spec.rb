describe "Merb::ResourceController::ActionDescriptor" do
  
  it "should raise if no action is given" do
    lambda { Merb::ResourceController::ActionDescriptor.new }.should raise_error
  end
  
  it "should raise if more than one format restriction was specified" do
    provided_formats = [ :html, :xml, :json, :yml ]
    options = { :provides => :xml, :does_not_provide => :json, :only_provides => :yml }
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, options) }.should raise_error
    options = { :provides => :xml, :does_not_provide => :json }
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, options) }.should raise_error  
    options = { :provides => :xml, :only_provides => :json }
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, options) }.should raise_error    
  end
    
  it "should allow valid format restriction apis" do
    provided_formats = [ :html, :xml, :json, :yml ]
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :provides => :xml)         }.should_not raise_error
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :does_not_provide => :xml) }.should_not raise_error    
    lambda { Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :only_provides => :xml)    }.should_not raise_error    
  end
        
  it "should be able to infer the format restriction api" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats)
    p.format_restriction_api.should == nil
    p.has_format_restriction?.should be_false
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :provides => :xml)
    p.format_restriction_api.should == :provides
    p.has_format_restriction?.should be_true
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :provides => [ :xml, :json ])
    p.format_restriction_api.should == :provides
    p.has_format_restriction?.should be_true
  end
            
  it "should be able to infer the restricted formats" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats)
    p.restricted_formats.should be_empty
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :provides => :xml)
    p.restricted_formats.should == [ :xml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats, :provides => [ :xml, :json ])
    p.restricted_formats.should == [ :xml, :json ]
  end
  
      
  it "should remember the action it is proxying" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats)
    p.action_name.should == :index
  end    
      
  it "should know about the module that defines the action" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats)
    p.action_module.should == Merb::ResourceController::Actions::Index
  end
        
  it "should know about the module that defines the flash support" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:index, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_false
    p.flash_module.should == nil
    p = Merb::ResourceController::ActionDescriptor.new(:show, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_false
    p.flash_module.should == nil
    p = Merb::ResourceController::ActionDescriptor.new(:new, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_false
    p.flash_module.should == nil
    
    p = Merb::ResourceController::ActionDescriptor.new(:edit, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_false
    p.flash_module.should == nil
    
    p = Merb::ResourceController::ActionDescriptor.new(:create, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_true
    p.flash_module.should == Merb::ResourceController::Actions::Create::FlashSupport
    
    p = Merb::ResourceController::ActionDescriptor.new(:update, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_true
    p.flash_module.should == Merb::ResourceController::Actions::Update::FlashSupport
    
    p = Merb::ResourceController::ActionDescriptor.new(:destroy, provided_formats)
    p.supports_flash_messages?.should be_false
    p.has_flash_module?.should be_true
    p.flash_module.should == Merb::ResourceController::Actions::Destroy::FlashSupport
    
  end  
      
  it "should be able to infer the content_type_handler_method" do
    provided_formats = [ :html, :xml, :json, :yml ]
    p = Merb::ResourceController::ActionDescriptor.new(:create, provided_formats)
    # builtin formats
    p.content_type_handler_method(:html, :success).should == "html_response_on_successful_create"
    p.content_type_handler_method(:html, :failure).should == "html_response_on_failed_create"
    p.content_type_handler_method(:xml, :success).should  == "xml_response_on_successful_create"
    p.content_type_handler_method(:xml, :failure).should  == "xml_response_on_failed_create"
    p.content_type_handler_method(:json, :success).should == "json_response_on_successful_create"
    p.content_type_handler_method(:json, :failure).should == "json_response_on_failed_create"
    p.content_type_handler_method(:yml, :success).should  == "yml_response_on_successful_create"
    p.content_type_handler_method(:yml, :failure).should  == "yml_response_on_failed_create"
    # custom formats                                         
    p.content_type_handler_method(:foo, :success).should  == "foo_response_on_successful_create"
    p.content_type_handler_method(:foo, :failure).should  == "foo_response_on_failed_create"    
  end
        
  it "should be able to register content type handlers" do
    provided_formats = [ :html, :xml, :json, :yml ]
    
    p = Merb::ResourceController::ActionDescriptor.new(:create, provided_formats)
    p.handle :json, :success
    # p.content_type_handler(:json, :success).should == "json_response_on_successful_create"
    # p.content_type_handler(:json, :failure).should be_nil
    
    # p = Merb::ResourceController::ActionDescriptor.new(:create, provided_formats)
    # p.handle [ :xml, :json ], :success
    # p.content_type_handler(:xml, :succes).should == "xml_response_on_successful_create"
    # p.content_type_handler(:xml, :failure).should  be_nil
    # p.content_type_handler(:json, :succes).should == "json_response_on_successful_create"
    # p.content_type_handler(:json, :failure).should  be_nil
    #     
    # p = Merb::ResourceController::ActionDescriptor.new(:create, provided_formats)
    # p.handle [ :xml, :json ]
    # p.content_type_handler(:xml, :succes).should  == "xml_response_on_successful_create"
    # p.content_type_handler(:xml, :failure).should  == "xml_response_on_failed_create"
    # p.content_type_handler(:json, :succes).should == "json_response_on_successful_create"
    # p.content_type_handler(:json, :failure).should == "json_response_on_failed_create"
  end
  
end