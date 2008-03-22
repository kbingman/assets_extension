module Admin::AssetHelper
  
  def dom_id(name, object)
    "#{name}_#{object.id}"
  end
  
  def tag_listing(asset)
    # asset.metatags.collect{|t| t.name}.join(", ")
    result = []
    asset.metatags.each do |tag|
     result << link_to(tag.name, asset_index_url(:tag => tag.name))
   end
   result.join(", ")
  end
  
end