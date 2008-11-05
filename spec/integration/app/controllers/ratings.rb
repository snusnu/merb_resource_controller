class Ratings < Application
  controlling :ratings do |r|
    r.belongs_to [ :article, :comment ]
  end
end