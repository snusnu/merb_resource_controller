module Community

  class Comments < Application
    controlling "Community::Comment" do |c|
      c.belongs_to :article
    end
  end

end