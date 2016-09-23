class IlluminaC::StockLibraryTube < Sequencescape::MultiplexedLibraryTube

  def can_be_passed?
    state == ("pending" || "started")
  end

end
