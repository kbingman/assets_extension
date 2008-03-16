class Admin::AssetController < ApplicationController
  
  def initialize
    super
    @cache = ResponseCache.instance
  end
  
  def index
    term = params['search'].downcase + '%' if params['search']
    condition = [ 'LOWER(title) LIKE ? or LOWER(caption) LIKE ?', '%' + term, '%' + term  ] if term

    @mark_term = params['search']
    @tag = params['tag']
    if @mark_term
      @assets = Asset.find(:all, :conditions => condition, :order => 'created_at DESC')
    elsif @tag
      @assets = Metatag.find_by_name(@tag).assets
    else
      @assets = Asset.find(:all, :conditions => 'parent_id is null', :order => 'created_at DESC')
    end
    if request.xhr?
      render :partial => 'asset_table', :layout => false
      return
    end
  end
  
  def new
    @asset = Asset.new
    render :template => "admin/asset/edit" if handle_new_or_edit_post
  end
  
  def edit
    @asset = Asset.find_by_id(params[:id])
    handle_new_or_edit_post
  end
  
  def remove
    @asset = Asset.find_by_id(params[:id])
    if request.post?
      @asset.destroy
      announce_removed
      redirect_to asset_index_url
    end
  end
  
  def clear_cache
    if request.post?
      @cache.clear
      announce_cache_cleared
      redirect_to '/admin/assets'
    else
      render :text => 'Do not access this URL directly.'
    end
  end
  
  # rjs
  def add_bucket
    @asset = Asset.find(params[:id])
    if (session[:bucket] ||= {}).key?(url(@asset))
      render :nothing => true and return
    end
    args = asset_image_args_for(@asset, :thumbnail, :id => "#{@asset.id}", :title => "#{@asset.title}" )
    session[:bucket][url(@asset)] = args
  end

  def clear_bucket
    session[:bucket] = nil
  end
  
  protected
  
    def asset_image_args_for(asset, thumbnail = :icon, options = {})
      # thumb_size = Array.new(2).fill(Asset.attachment_options[:thumbnails][thumbnail].to_i).join('x')
      # options    = options.reverse_merge(:title => "#{asset.title}")
      [url(asset, thumbnail), options]
    end
  
    def announce_saved(message = nil)
      flash[:notice] = message || "Asset saved below."
    end
   
    def announce_validation_errors
      flash[:error] = "Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing."
    end
   
    def announce_removed
      flash[:notice] = "Asset has been deleted."
    end
    
    def continue_url(options)
      options[:redirect_to] || (params[:continue] ? asset_edit_url(:id => @asset.id) : asset_index_url)
    end
    
    def announce_cache_cleared
      flash[:notice] = "The asset cache was successfully cleared."
    end
    
    def clear_model_cache(url)
      @cache.expire_response(url)      
    end
    
    def url(asset, thumbnail = nil)
      thumb_path = thumbnail || 'original'
      %{/images/#{asset.id}/#{thumb_path}/#{asset.filename}}
    end
  
    def handle_new_or_edit_post(options = {})
      options.symbolize_keys
      if request.post?
        @asset.attributes = params[:asset]
        @asset.title = @asset.basename if @asset.title.blank?
        if @asset.save
          clear_model_cache(url(@asset, nil))
          # @asset.thumbnails.each do |thumbnail|
          #  clear_model_cache(url(@asset, thumbnail.thumbnail.to_s))
          # end
          announce_saved
          redirect_to continue_url(options)
          return false
        else
          announce_validation_errors
        end
      end
      true
    end
  
end
