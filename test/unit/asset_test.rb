require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase

  def test_should_create_record
    asset = create
    assert asset.valid?, "Asset was invalid:/n#{asset.to_yaml}"
  end
  
  def test_should_require_title
    # asset = create(:title => nil)
    # assert_not_nil asset.errors.on(:title), "No title should raise an error"
  end
  
  private
    
    def create(options={})
      Asset.create(@@asset_default_values.merge(options))
    end
  
end