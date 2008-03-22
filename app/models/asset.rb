class Asset < ActiveRecord::Base
  
  order_by 'title'
  
  has_attachment :content_type => :image,
                 :storage => :db_file, :max_size => 2.megabytes,
                 :processor => :rmagick,
                 :resize_to => '1024x1024',
                 :thumbnails => {}
  validates_as_attachment
  
  has_many :attachments
  has_many :pages, :through => :attachments
  
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by'
  
  attr_accessor :request, :response
  
  def cache?
    true
  end

  # Hacked image method to get the image from the database. This seems to be a leftover from when I made thumbnails on upload. 
  def image_data(thumbnail = nil)
    thumbnail.nil? ? current_data : thumbnails.find_by_thumbnail(thumbnail.to_s).current_data
  end
  
  def full_filename
    filename
  end
  
  def public_filename(size = :original)
    %{/images/#{self.id}/#{size}/#{self.filename}}
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

