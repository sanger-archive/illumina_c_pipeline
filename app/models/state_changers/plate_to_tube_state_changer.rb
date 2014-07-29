class StateChangers::PlateToTubeStateChanger < StateChangers::QcCompletablePlateStateChanger
  def move_to!(state, reason, customer_accepts_responsibility = false)
    super
    transfer_to_tubes! if state == 'qc_complete'
  end

  def transfer_to_tubes!
    plate_to_tube_template.create!(
        :user   => user_uuid,
        :source => labware_uuid
      )
  end
  private :transfer_to_tubes!

  def plate_to_tube_template
    api.transfer_template.find(
      Settings.transfer_templates["Transfer wells to MX library tubes by submission"]
    )
  end
  private :plate_to_tube_template

end
