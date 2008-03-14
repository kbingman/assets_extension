require 'RMagick'

class ImageController < ApplicationController
  session :off
  
  no_login_required
  # caches_page :show # Normal Rails caching method
  
  attr_accessor :config, :cache
  
  # Radiant caching method
  def initialize
    @config = Radiant::Config
    @cache = ResponseCache.instance
  end
  
  def show_image
    response.headers.delete('Cache-Control')
    url = request.request_uri.to_s
    if (request.get? || request.head?) and (@cache.response_cached?(url))
      @cache.update_response(url, response, request)
      @performed_render = true
    else
      resize_uncached_image
    end
  end
  
  protected
  
    def resize_uncached_image(quality=72)
      begin
        size_name = params[:size]
        asset = Asset.find_by_id(params[:id])
        size = @config["assets.#{size_name}"]
        image = Magick::Image.from_blob(asset.image_data).first
        image.change_geometry(size) { |cols, rows, img| img.crop_resized!(cols, rows)}
        send_data(image.to_blob() {self.quality = quality},
                  :filename => asset.filename,
                  :type => asset.content_type,
                  :disposition => 'inline')
        @cache.cache_response(image_url(asset, size_name), response)
      rescue
        # can't display an image for any reason at all.
      end
    end
    
    def image_url(asset, size)
      %{/images/#{asset.id}/#{size}/#{asset.filename}}
    end
end