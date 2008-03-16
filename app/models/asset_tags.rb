module AssetTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  desc %{
    The namespace for referencing images and assets.  You may specify the 'name'
    attribute on this tag for all contained tags to refer to that asset.  
    
    *Usage:* 
    <pre><code><r:asset [name="name"] >...</r:asset:each></code></pre>
  }    
  tag 'asset' do |tag|
    tag.locals.asset = Asset.find_by_title(tag.attr['title'])
    tag.expand
  end
  
  desc %{
    
    *Usage:* 
    <pre><code><r:image [asset_id="asset_id"] ></code></pre>
  }    
  tag 'asset:image' do |tag|
    options = tag.attr.dup
    raise TagError, "'title' attribute required" unless title = options.delete('title') or tag.locals.asset
    asset = tag.locals.asset || Asset.find_by_title(tag.attr['title'])
    size = options.delete('size') || 'normal'
    # path = asset.image_url(size)
    alt = "alt='#{asset.title}'" unless tag.attr['alt'] rescue nil
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes << alt unless alt.nil?
    %{<img src="#{asset.image_url(size)}" #{attributes unless attributes.empty?} />} rescue nil
  end
  
  desc %{

    *Usage:* 
    <pre><code><r:image [asset_id="asset_id"] ></code></pre>
  }    
  tag 'asset:url' do |tag|
    options = tag.attr.dup
    raise TagError, "'title' attribute required" unless title = options.delete('title') or tag.locals.asset
    asset = tag.locals.asset || Asset.find_by_title(tag.attr['title'])
    size = options.delete('size') || 'normal'
    asset.image_url(size)  rescue nil
  end
  
  [:filename, :title, :caption, :content_type, :size, :width, :height, :id].each do |key|
    desc %{
      Renders the `#{key}' attribute of the asset.     
      The 'title' attribute is required on this tag or the parent tag.
    }
    tag "asset:#{key}" do |tag|
      raise TagError, "'title' attribute required" unless title = tag.attr['title'] or tag.locals.asset
      asset = tag.locals.asset || Asset.find_by_title(tag.attr['title'])
      asset.attributes["#{key}"] rescue nil
    end
  end
  
end