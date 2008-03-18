module PageAssetAssociations
  def self.included(base)
    base.class_eval {
      has_and_belongs_to_many :assets
    }
  end
  
end