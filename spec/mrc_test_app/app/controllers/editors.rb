class Editors < Application
  
  controlling :editor, :singleton => true do |e|
    e.belongs_to :article
  end
  
end