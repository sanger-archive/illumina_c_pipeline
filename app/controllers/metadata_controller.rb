class MetadataController < ApplicationController

  def index
  end

  def show
    @metadata = api.process_metadatum_collection.find(params[:id]).metadata
  end

  def new
  end

  def create
    metadata = params[:metadata].inject({}) {|result, metadatum| result[metadatum[:key]] = metadatum[:value]; result}
    response = api.process_metadatum_collection.create!(user: "user-uuid", asset: "asset-uuid", metadata: metadata)
    redirect_to(metadatum_path(response.uuid), notice: "Metadata was added successfully")
  end

end