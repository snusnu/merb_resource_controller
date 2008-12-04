module Merb
  module ResourceController
    
    module Actions

      module Index
        
        # def index
        #   @articles = Article.all
        #   display @articles
        # end
        
        def index
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
          only_provides :html
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
          only_provides :html
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
          load_resource
          set_member(new_member(params[member_name]))
          if member.save
            options = flash_supported? ? { :message => successful_create_messages } : {}
            redirect redirect_on_successful_create, options
          else
            message.merge!(failed_create_messages) if flash_supported?
            render :new
          end
        end
        
        def redirect_on_successful_create
          target = singleton_controller? ? member_name : member
          resource(*(has_parent? ? parents + [ target ] : [ target ]))
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
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          if requested_resource.update_attributes(params[member_name])
            options = flash_supported? ? { :message => successful_update_messages } : {}
            redirect redirect_on_successful_update, options
          else
            message.merge!(failed_update_messages) if flash_supported?
            display requested_resource, :edit
          end
        end
        
        def redirect_on_successful_update
          target = singleton_controller? ? member_name : member
          resource(*(has_parent? ? parents + [ target ] : [ target ]))
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
          load_resource
          raise Merb::ControllerExceptions::NotFound unless requested_resource
          if requested_resource.destroy
            options = flash_supported? ? { :message => successful_destroy_messages } : {}
            redirect redirect_on_successful_destroy, options
          else
            raise Merb::ControllerExceptions::InternalServerError
          end
        end
        
        def redirect_on_successful_destroy
          if singleton_controller?
            has_parent? ? resource(parent) : '/'
          else
            resource(*(has_parent? ? parents + [ collection_name ] : [ collection_name ]))
          end
        end
        
      end

    end
    
  end
end