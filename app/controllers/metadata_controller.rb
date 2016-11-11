class MetadataController < ApplicationController

  def create
    metadata = metadata_hash
    api.custom_metadatum_collection.create!(user: current_user_uuid, asset: params[:asset_id], metadata: metadata)
    redirect_to(:back, notice: "Metadata was added successfully")
  end

  def update
    metadata = metadata_hash
    api.custom_metadatum_collection.find(params[:id]).update_attributes!(metadata: metadata)
    redirect_to(:back, notice: "Metadata was updated successfully")
  end

  def metadata_hash
    key_values = params[:metadata].map {|metadatum| [metadatum[:key], metadatum[:value]]}
    Hash[key_values.reject {|k, v| k.blank? || v.blank? }]
  end

end