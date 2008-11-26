class Editors < Application
  
  controlling(:editors, :singleton => true) do |e|
    e.belongs_to :article
  end
  
  def redirect_on_successful_create
    resource(parent, :editor)
  end
    
  def redirect_on_successful_update
    resource(parent, :editor)
  end
      
  def redirect_on_successful_destroy
    resource(parent)
  end
  
end