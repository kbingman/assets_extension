class Asset < ActiveRecord::Base
  
  order_by 'title'
  
  has_attachment :storage => :db_file, :max_size => 2.megabytes,
                 :processor => :rmagick,
                 :resize_to => '800x800'
                 # :thumbnails => { :thumbnail => '100x100', :icon => '42x42!' }
  validates_as_attachment
  
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  
  attr_accessor :request, :response
  
  def cache?
    true
  end

  # Hacked image method to get the image from the database. Need to rewrite this so that it is a bit more elegant.
  def image_data(thumbnail = nil)
    if thumbnail.nil?
      current_data
    else
      thumbnails.find_by_thumbnail(thumbnail.to_s).current_data
    end
  end
  
  def full_filename
    filename
  end
  
  def basename
    File.basename(filename, ".*") if filename
  end
  
  def extension
    filename.split('.').last.downcase
  end
  
  def process(request, response)
    @request, @response = request, response
    @response.headers['Content-Type'] = content_type 
    headers.each { |k,v| @response.headers[k] = v }
    @response.body = render
    @request, @response = nil, nil
  end

end

