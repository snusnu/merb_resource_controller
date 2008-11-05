class Comments < Application
  controlling :comments do |c|
    c.belongs_to :article
  end
end