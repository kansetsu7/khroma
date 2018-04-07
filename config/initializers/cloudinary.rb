Cloudinary.config do |config|
  cl_config = Rails.application.config_for(:cloudinary)
  config.cloud_name = cl_config['cloud_name']
  config.api_key = cl_config['api_key']
  config.api_secret = cl_config['api_secret']
  config.secure = true
  config.cdn_subdomain = true
end