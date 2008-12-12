module Community

  class Ratings < Application
    controlling "Community::Rating" do |r|
      r.belongs_to [ :article, "Community::Comment" ]
    end
  end

end