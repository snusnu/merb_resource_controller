module Merb
  module ResourceController
    
    module Actions

      module Index
        # def index
        #   @articles = Article.all
        #   display @articles
        # end
        def index
          collection = load_collection
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
          member = load_member(params[:id])
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
          member = new_member
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
          member = load_member(params[:id])
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
          member = new_member(params[member_name])
          if member.save
            options = flash_supported? ? { :message => successful_create_messages } : {}
            redirect resource(member), options
          else
            message.merge!(failed_create_messages) if flash_supported?
            render :new
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
          member = load_member(params[:id])
          raise Merb::ControllerExceptions::NotFound unless member
          if member.update_attributes(params[member_name])
            options = flash_supported? ? { :message => successful_update_messages } : {}
            redirect resource(member), options
          else
            message.merge!(failed_update_messages) if flash_supported?
            display member, :edit
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
          member = load_member(params[:id])
          raise Merb::ControllerExceptions::NotFound unless member
          if member.destroy
            options = flash_supported? ? { :message => successful_destroy_messages } : {}
            redirect resource(collection_name), options
          else
            raise Merb::ControllerExceptions::InternalServerError
          end
        end
      end

    end
    
  end
end