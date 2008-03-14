class AssetListingPage < Page
  
  include Radiant::Taggable
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    if url =~ %r{^#{ self.url }(([0-9])+(\+)?)+(\/)?}
      children.find_by_class_name('AssetDisplayPage')
    else
      super
    end
  end
  
  
end