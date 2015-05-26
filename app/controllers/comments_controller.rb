class CommentsController < ApplicationController

  def create

    api.plate.find(plate_uuid).comments.create!(
      :description=>params["comment-description"],
      :user => current_user_uuid
    )
    redirect_to illumina_c_plate_path(plate_uuid)
  end

  private

  def plate_uuid
    params[:illumina_c_plate_id]
  end
end
