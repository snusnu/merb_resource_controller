module Merb
  module ResourceController
    
    module Actions

      module Index
        
        # def index
        #   @articles = Article.all
        #   display @articles
        # end
        
        def index
          set_collection(load_collection)
          display collection
        end
        
      end

      module Show
        
        # def show(id)
        #   @article = Article.get(id)
        #   raise NotFound unless @article
        #   display @article
        # end
        
        def show
          set_member(load_member(params[:id]))
          raise Merb::ControllerExceptions::NotFound unless member
          display member
        end
        
      end

      module New
        
        # def new
        #   only_provides :html
        #   @article = Article.new
        #   display @article
        # end
        
        def new
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
          set_member(load_member(params[:id]))
          raise Merb::ControllerExceptions::NotFound unless member
          display member
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
          resource(*(has_parent? ? [ parent, member ] : [ member ]))
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
          set_member(load_member(params[:id]))
          raise Merb::ControllerExceptions::NotFound unless member
          if member.update_attributes(params[member_name])
            options = flash_supported? ? { :message => successful_update_messages } : {}
            redirect redirect_on_successful_update, options
          else
            message.merge!(failed_update_messages) if flash_supported?
            display member, :edit
          end
        end
        
        def redirect_on_successful_update
          resource(*(has_parent? ? [ parent, member ] : [ member ]))
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
          set_member(load_member(params[:id]))
          raise Merb::ControllerExceptions::NotFound unless member
          if member.destroy
            options = flash_supported? ? { :message => successful_destroy_messages } : {}
            redirect redirect_on_successful_destroy, options
          else
            raise Merb::ControllerExceptions::InternalServerError
          end
        end
        
        def redirect_on_successful_destroy
          resource(*(has_parent? ? [ parent, collection_name ] : [ collection_name ]))
        end
        
      end

    end
    
  end
end