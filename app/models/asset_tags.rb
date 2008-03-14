module AssetTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    The namespace for referencing images and assets.  You may specify the 'name'
    attribute on this tag for all contained tags to refer to that asset.  
    
    *Usage:* 
    <pre><code><r:asset [name="name"] >...</r:asset:each></code></pre>
  }    
  tag 'assets' do |tag|
    raise TagError, "'name' attribute required" unless name = tag.attr['name'] or tag.locals.asset
    tag.locals.asset = Asset.find_by_filename(tag.attr['name'])
    tag.expand
  end
  
  desc %{
    
    *Usage:* 
    <pre><code><r:image [asset_id="asset_id"] ></code></pre>
  }    
  tag 'assets:image' do |tag|
    options = tag.attr.dup
    raise TagError, "'name' attribute required" unless name = options.delete('name') or tag.locals.asset
    asset = tag.locals.asset || Asset.find_by_filename(tag.attr['name'])
    size = options.delete('size') || 'normal'
    path = filepath(asset, size)
    alt = "alt='#{asset.title}'" unless tag.attr['alt']
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes << alt unless alt.nil?
    %{<img src="#{filepath(asset, size)}" #{attributes unless attributes.empty?} />}
  end
  
  desc %{

    *Usage:* 
    <pre><code><r:image [asset_id="asset_id"] ></code></pre>
  }    
  tag 'assets:url' do |tag|
    options = tag.attr.dup
    raise TagError, "'name' attribute required" unless name = options.delete('name') or tag.locals.asset
    asset = tag.locals.asset || Asset.find_by_filename(tag.attr['name'])
    size = options.delete('size') || 'normal'
    filepath(asset, size)
  end
  
  [:filename, :title, :caption, :content_type, :size, :width, :height, :id].each do |key|
    desc %{
      Renders the `#{key}' attribute of the asset.     
      The 'name' attribute is required on this tag or the parent tag.
    }
    tag "assets:#{key}" do |tag|
      options = tag.attr.dup
      raise TagError, "'name' attribute required" unless name = options.delete('name') or tag.locals.asset
      asset = tag.locals.asset || Asset.find_by_filename(tag.attr['name'])
      asset.attributes["#{key}"]
    end
  end
  
  private
  
    def filepath(asset, size)
      filepath = "/images/#{asset.id}/#{size}/#{asset.basename}.#{asset.extension}"
    end
  
end