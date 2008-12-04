module Community

  class Ratings < Application
    controlling "Community::Rating" do |r|
      r.belongs_to [ :article, :comment ]
    end
  end

end