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
  tag 'assets' do |tag|
    id = asset_id.split('/').last
    asset = Asset.find(id)
    tag.locals.asset = asset
    tag.expand
  end
  
  tag 'tag' do |tag|
    name = asset_id.split('/').first
    metatag = Metatag.find_by_name(name)
    tag.locals.metatag = metatag
    tag.expand
  end
  
  def virtual?
    true
  end
    
end