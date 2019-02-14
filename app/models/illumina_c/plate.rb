class IlluminaC::Plate < Sequencescape::Plate
  # Returns a plate instance that has been coerced into the appropriate class if necessary.  Typically
  # this is only done at the end of the pipelines when extra functionality is required when dealing
  # with the transfers into tubes.
  def coerce
    return self unless qc_complete? and is_a_final_pooling_plate?
    coerce_to(IlluminaC::FinalPlate)
  end

  FINAL_POOLING_PLATE_PURPOSES = [
    'ILC AL Libs Tagged',
    'ILC Lib PCR-XP',
    'ILC Lib Chromium'
  ]

  attribute_group :barcode do
    attribute_accessor :prefix, :number     # The pieces that make up a barcode
    attribute_accessor :ean13               # The EAN13 barcode number
    attribute_accessor :machine             # Barcode suitable for code39
    attribute_accessor :type                # Frustratingly obtuse indicator of label type (1 = plate, 2= tube)
  end

  def is_a_final_pooling_plate?
    FINAL_POOLING_PLATE_PURPOSES.include?(plate_purpose.name)
  end
  private :is_a_final_pooling_plate?
end
