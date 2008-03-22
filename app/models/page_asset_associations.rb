module PageAssetAssociations
  def self.included(base)
    base.class_eval {
      has_many :asset_associations
      has_many :assets, :through => :asset_associations
    }
  end
  
end