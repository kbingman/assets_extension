# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
require File.dirname(__FILE__)+'/lib/geometry'
require 'tempfile'

class AssetsExtension < Radiant::Extension
  version "0.3"
  description "Describe your extension here"
  url "http://keithbingman.com/assets"
  
  define_routes do |map|
    # map.connect '/admin/assets/:action', :controller => 'admin/asset'
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
      # image.images_show     'images/:id/:thumbnail/:filename.:ext',     :action => 'show'
      image.images_show       'images/:id/:size/:filename.:ext',               :action => 'show_image'
    end
  end
  
  def activate
    # Contents of attachment_fu/init.rb
    
    Tempfile.class_eval do
      # overwrite so tempfiles use the extension of the basename.  important for rmagick and image science
      def make_tmpname(basename, n)
        ext = nil
        sprintf("%s%d-%d%s", basename.to_s.gsub(/\.\w+$/) { |s| ext = s; '' }, $$, n, ext)
      end
    end
    
    ActiveRecord::Base.send(:extend, Technoweenie::AttachmentFu::ActMethods)
    Technoweenie::AttachmentFu.tempfile_path = ATTACHMENT_FU_TEMPFILE_PATH if Object.const_defined?(:ATTACHMENT_FU_TEMPFILE_PATH)
    FileUtils.mkdir_p Technoweenie::AttachmentFu.tempfile_path
    
    AssetDisplayPage
    AssetListingPage
    
    Page.send :include, AssetTags
    UserActionObserver.send :include, ObserveAssets
    Admin::PageController.send :include, AssetsInterface
    
    admin.tabs.add "Assets", "/admin/assets", :after => "Pages", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Assets"
  end
  
end