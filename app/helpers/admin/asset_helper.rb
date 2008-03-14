module Admin::AssetHelper
  
  def image_url(asset, size='normal')
    images_show_url(:id => asset.id, :size => size, :filename => asset.basename, :ext => asset.extension)
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