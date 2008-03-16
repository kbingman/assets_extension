require_dependency 'application'

class AssetsExtension < Radiant::Extension
  version "0.3"
  description "Describe your extension here"
  url "http://keithbingman.com/assets"
  
  define_routes do |map|

    map.with_options(:controller => 'admin/asset') do |asset|
      asset.asset_index     'admin/assets',                         :action => 'index'
      asset.asset_edit      'admin/assets/edit/:id',                :action => 'edit'
      asset.asset_new       'admin/assets/new',                     :action => 'new'
      asset.asset_remove    'admin/assets/remove/:id',              :action => 'remove'
      # asset.asset_tags      'admin/assets/:tag',                  :action => 'index', :tag => ''
      asset.add_bucket         'admin/assets/add_bucket/:id',       :action => 'add_bucket'
      asset.clear_bucket       'admin/assets/clear_bucket/:id',     :action => 'clear_bucket'
    end
    map.with_options(:controller => 'image') do |image|
      image.images_show       'images/:id/:size/:filename.:ext',    :action => 'show_image'
    end
  end
  
  def activate
  
    AssetDisplayPage
    AssetListingPage
    
    Page.send :include, AssetTags
    UserActionObserver.send :include, ObserveAssets
    Admin::PageController.send :include, AssetsInterface
    
    # Default sizes for the images. Other sizes can be added in the Config table using 
    # "assets.foo" = "[width]x[height]". You can also use RMagick flags for cropping. 
    
    Radiant::Config["assets.icon"] = '42x42!'
    Radiant::Config["assets.thumbnail"] = '150x150'
    Radiant::Config["assets.normal"] = '480x480'
    
    admin.tabs.add "Assets", "/admin/assets", :after => "Pages", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Assets"
  end
  
end