module Merb
  module ResourceController
    
    module Actions

      module Index
        
        # def index
        #   @articles = Article.all
        #   display @articles
        # end
        
        def index
          set_action_specific_provides(:index)
          load_resource
          display requested_resource
        end
        
      end

      module Show
        
        # def show(id)
        #   @article = Article.get(id)
        #   raise NotFound unless @article
        #   display @article
        # end
        
        def show
          set_action_specific_provides(:show)
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          display requested_resource
        end
        
      end

      module New
        
        # def new
        #   only_provides :html
        #   @article = Article.new
        #   display @article
        # end
        
        def new
          set_action_specific_provides(:new)
          load_resource
          set_member(new_member)
          display member
        end
        
      end

      module Edit
        
        # def edit(id)
        #   only_provides :html
        #   @article = Article.get(id)
        #   raise NotFound unless @article
        #   display @article
        # end
        
        def edit
          set_action_specific_provides(:edit)
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          display requested_resource
        end
        
      end

      module Create
        
        # def create(article)
        #   @article = Article.new(article)
        #   if @article.save
        #     redirect resource(@article), :message => { :notice => "Article was successfully created" }
        #   else
        #     message[:error] = "Article failed to be created"
        #     render :new
        #   end
        # end
        
        def create
          set_action_specific_provides(:create)
          load_resource
          set_member(new_member)
          if member.save
            handle_successful_create
          else
            handle_failed_create
          end
        end
        
        protected
                
        def handle_successful_create
          handle_content_type(:create, content_type, :success)
        end
        
        def handle_failed_create
          handle_content_type(:create, content_type, :failure)
        end
        
        
        def html_response_on_successful_create
          options = flash_messages_for?(:create) ? { :message => successful_create_messages } : {}
          redirect redirect_on_successful_create, options          
        end
                
        def html_response_on_failed_create
          message.merge!(failed_create_messages) if flash_messages_for?(:create)
          render :new, :status => 406         
        end
        
                
        def xml_response_on_successful_create
          display member, :status => 201, :location => resource(member)
        end
                
        def xml_response_on_failed_create
          display member.errors, :status => 422
        end        
        
             
        def json_response_on_successful_create
          display member, :status => 201, :location => resource(member)         
        end
                
        def json_response_on_failed_create
          display member.errors, :status => 422
        end
        
        
        def redirect_on_successful_create
          target = singleton_controller? ? member_name : member
          resource(*(has_parent? ? parents + [ target ] : [ target ]))
        end
        
        module FlashSupport

          protected

          def successful_create_messages
            { :notice => "#{member.class.name} was successfully created" }
          end

          def failed_create_messages
            { :error => "Failed to create new #{member.class.name}" }
          end
          
        end
        
      end

      module Update
        
        # def update(id, article)
        #   @article = Article.get(id)
        #   raise NotFound unless @article
        #   if @article.update_attributes(article)
        #      redirect resource(@article), :message => { :notice => "Article was successfully updated" }
        #   else
        #     display @article, :edit
        #   end
        # end
        
        def update
          set_action_specific_provides(:update)
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          if requested_resource.update(params[member_name])
            handle_successful_update
          else
            handle_failed_update
          end
        end
        
        protected
        
        def handle_successful_update
          handle_content_type(:update, content_type, :success)
        end
        
        def handle_failed_update
          handle_content_type(:update, content_type, :failure)
        end
        
        
        def html_response_on_successful_update
          options = flash_messages_for?(:update) ? { :message => successful_update_messages } : {}
          redirect redirect_on_successful_update, options       
        end
                
        def html_response_on_failed_update
          message.merge!(failed_update_messages) if flash_messages_for?(:update)
          display requested_resource, :edit, :status => 406
        end
        
                
        def xml_response_on_successful_update
          "" # render no content, just 200 (OK) status.
        end
                
        def xml_response_on_failed_update
          display member.errors, :status => 422
        end        
        
             
        def json_response_on_successful_update
          "" # render no content, just 200 (OK) status.
        end
                
        def json_response_on_failed_update
          display member.errors, :status => 422
        end
        
        def redirect_on_successful_update
          target = singleton_controller? ? member_name : member
          resource(*(has_parent? ? parents + [ target ] : [ target ]))
        end
        
        module FlashSupport

          protected

          def successful_update_messages
            { :notice => "#{member.class.name} was successfully updated" }
          end

          def failed_update_messages
            { :error => "Failed to update #{member.class.name}" }
          end
          
        end
        
      end

      module Destroy
        
        # def destroy(id)
        #   @article = Article.get(id)
        #   raise NotFound unless @article
        #   if @article.destroy
        #     redirect resource(:articles)
        #   else
        #     raise InternalServerError
        #   end
        # end
        
        def destroy
          set_action_specific_provides(:destroy)
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          if requested_resource.destroy
            handle_successful_destroy
          else
            handle_failed_destroy
          end
        end
        
        protected
        
        def handle_successful_destroy
          handle_content_type(:destroy, content_type, :success)
        end
        
        def handle_failed_destroy
          raise Merb::ControllerExceptions::InternalServerError
        end
        
        
        def html_response_on_successful_destroy
          options = flash_messages_for?(:destroy) ? { :message => successful_destroy_messages } : {}
          redirect redirect_on_successful_destroy, options 
        end
                
        def xml_response_on_successful_destroy
          "" # render no content, just 200 (OK) status.
        end
             
        def json_response_on_successful_destroy
          "" # render no content, just 200 (OK) status.
        end
        
        
        def redirect_on_successful_destroy
          if singleton_controller?
            has_parent? ? resource(parent) : '/'
          else
            resource(*(has_parent? ? parents + [ collection_name ] : [ collection_name ]))
          end
        end
        
        module FlashSupport

          protected

          def successful_destroy_messages
            { :notice => "#{member.class.name} was successfully destroyed" }
          end

          def failed_destroy_messages
            { :error => "Failed to destroy #{member.class.name}" }
          end
          
        end
        
      end

    end
    
  end
end