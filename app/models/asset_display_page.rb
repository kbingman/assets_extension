class AssetDisplayPage < Page
  
  include Radiant::Taggable 
  
  def asset_id
    url = request.request_uri unless request.nil?
    regexp = %r{#{parent.url}(([a-z0-9\/])+(\+)?)+(\/)?$}
    asset_id = url.match(regexp)[1]
    asset_id
  end
  
  desc %{
    The namespace for referencing tags.   
    
    *Usage:* 
    <pre><code></code></pre>
  }
  tag 'asset' do |tag|
    id = asset_id.split('/').last
    asset = Asset.find(id)
    tag.locals.asset = asset
    tag.expand
  end
  
  #
  tag 'asset:page' do |tag|
    tag.locals.page = tag.globals.page
    tag.expand
  end
  
  def virtual?
    true
  end
    
end