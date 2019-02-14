require './lib/pmb_wrapper'

class BarcodeLabelsController < ApplicationController
  before_filter :initialize_printer_and_barcode_service
  # Handles printing a single label
  def individual
    if print([params[:label]])
      redirect_to(params[:redirect_to], :notice => "Barcode printed to #{@printer.name}")
    else
      redirect_to(params[:redirect_to], :error => "Barcode failed to print to #{@printer.name}")
    end
  end

  # Handles printing multiple labels
  def multiple
    if print(params[:labels].values)
      redirect_to(params[:redirect_to], :notice => "#{params[:labels].size} barcodes printed to #{@printer.try(:name)}")
    else
      redirect_to(params[:redirect_to], :error => "Barcodes failed to print to #{@printer.name}")
    end
  end

  private

  def initialize_printer_and_barcode_service
    raise StandardError, "No printer specified!" if params[:printer].blank?
    @printer = api.barcode_printer.find(params[:printer])
    @copies = params[:number].to_i
  end

  # Does the actual printing of the labels passed
  def print(labels)
    PmbWrapper.new(
      IlluminaCPipeline::Application.config.pmb_url,
      @printer.name,
      @printer.type.layout,
      labels*@copies
    ).print_label
  end
end
