module Admin::AssetHelper
  
  
  
  def tag_listing(asset)
    # asset.metatags.collect{|t| t.name}.join(", ")
    result = []
    asset.metatags.each do |tag|
     result << link_to(tag.name, asset_index_url(:tag => tag.name))
   end
   result.join(", ")
  end
  
end