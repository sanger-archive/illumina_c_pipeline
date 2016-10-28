class MetadataController < ApplicationController

  def create
    metadata = metadata_hash(params[:metadata])
    response = api.process_metadatum_collection.create!(user: current_user_uuid, asset: params[:asset_id], metadata: metadata)
    redirect_to(illumina_c_plate_path(params[:asset_id]), notice: "Metadata was added successfully")
  end

  def update
    metadata = metadata_hash(params[:metadata])
    api.process_metadatum_collection.find(params[:id]).update_attributes!(metadata: metadata)
    redirect_to(illumina_c_plate_path(params[:asset_id]), notice: "Metadata was updated successfully")
  end

  def metadata_hash(metadata)
    metadata.inject({}) {|result, metadatum| result[metadatum[:key]] = metadatum[:value] unless metadatum[:key].blank?; result}
  end

end