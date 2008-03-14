module AssetsInterface
  def self.included(base)
    base.class_eval {
      before_filter :add_asset_partials, :only => [:edit, :new]
      include InstanceMethods
    }
  end
  
  module InstanceMethods
    def add_asset_partials
      @buttons_partials ||= []
      @buttons_partials << "/admin/asset/bucket"
      # include_javascript '/javascripts/bucket'
      include_stylesheet 'admin/assets'
    end
  end
end