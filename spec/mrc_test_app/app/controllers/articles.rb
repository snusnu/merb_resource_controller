class Articles < Application
  provides :xml, :json
  controlling :articles
end