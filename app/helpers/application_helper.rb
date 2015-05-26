module ApplicationHelper

  def api
    Sequencescape::Api.new(IlluminaCPipeline::Application.config.api_connection_options)
  end

end
