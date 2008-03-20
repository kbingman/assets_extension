class AssetsExtension < Radiant::Extension
  version "0.4"
  description "Describe your extension here"
  url "http://keithbingman.com/assets"
  
  define_routes do |map|

    map.with_options(:controller => 'admin/asset') do |asset|
      asset.asset_index   'admin/assets',                           :action => 'index'
      asset.asset_edit    'admin/assets/edit/:id',                  :action => 'edit'
      asset.asset_new     'admin/assets/new',                       :action => 'new'
      asset.asset_remove  'admin/assets/remove/:id',                :action => 'remove'
      asset.add_bucket    'admin/assets/add_bucket/:id',            :action => 'add_bucket'
      asset.clear_bucket  'admin/assets/clear_bucket/:id',          :action => 'clear_bucket'
      asset.attach_asset  'admin/assets/attach/:asset/page/:page',  :action => 'attach_asset'
      asset.remove_asset  'admin/assets/remove/:asset/page/:page',  :action => 'remove_asset'
    end
    map.with_options(:controller => 'image') do |image|
      image.images_show     'images/:id/:size/:filename.:ext',  :action => 'show'
    end
  end
  
  def activate
    raise "The Shards extension is required and must be loaded first!" unless defined?(Shards)
    admin.page.index.add :sitemap_head, 'assets_extra_th', :before => "status_column_header"
    admin.page.index.add :node, 'assets_extra_td', :before => "status_column"
    admin.page.edit.add :form_bottom, '/admin/asset/assets_container', :before => "edit_buttons"
    
    require_dependency 'application'
    
    AssetDisplayPage
    AssetListingPage
    
    Page.class_eval {
      include PageAssetAssociations
      include AssetTags
    }
    UserActionObserver.send :include, ObserveAssets
    # Admin::PageController.send :include, AssetsInterface
    
    # Default sizes for the images used in the admin views. Other sizes can be added in the Config table using 
    # "assets.foo" = "[width]x[height]". You can also use RMagick flags for cropping. 
    
    Radiant::Config["assets.icon"] = '42x42!'
    Radiant::Config["assets.thumbnail"] = '100x100'
    
    admin.tabs.add "Assets", "/admin/assets", :after => "Pages", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Assets"
  end
  
end