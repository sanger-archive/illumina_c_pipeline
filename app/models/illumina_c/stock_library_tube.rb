class IlluminaC::StockLibraryTube < Sequencescape::MultiplexedLibraryTube

  def can_be_passed?
    ["pending", "started"].include? state
  end

  attribute_group :barcode do
    attribute_accessor :prefix, :number     # The pieces that make up a barcode
    attribute_accessor :ean13               # The EAN13 barcode number
    attribute_accessor :machine             # Barcode suitable for code39
    attribute_accessor :type                # Frustratingly obtuse indicator of label type (1 = plate, 2= tube)
  end
end
