require 'net/http'

# Quick and dirty PMB wrapper.
# - We are retiring Generic Lims ASAP (stories for replacement in progress)
# - The existing client requires rails 3.2
# - This forces us into a constant stream of gem updates.
# - Test coverage is lacking
class PmbWrapper
  def initialize(url, printer, layout, labels)
    @uri = URI(url)
    @layout = layout
    @printer = printer
    @labels = labels
  end

  def print_label
    req = Net::HTTP::Post.new(@uri.to_s)
    req.content_type = 'application/vnd.api+json'
    req.body = payload
    res = Net::HTTP.start(@uri.hostname, @uri.port) do |http|
      http.request(req)
    end
    res.code == '201'
  rescue Errno::ECONNREFUSED
    false
  end

  private

  def label_id
    IlluminaCPipeline::Application.config.barcode_type_label_id.fetch(@layout)
  end

  def plate_label(label)
    {
      main_label: {
        top_left: date,
        bottom_left: label[:machine],
        top_right: label[:stock_barcode],
        bottom_right: label[:text],
        barcode: label[:machine] || label[:ean13]
      }
    }
  end

  def tube_label(label)
    {
      main_label: {
        top_line: label[:text],
        bottom_line: date,
        round_label_top_line: label[:prefix],
        round_label_bottom_line: label[:number],
        barcode: label[:ean13]
      }
    }
  end

  def convert_label(label)
    case @layout
    when 1 then plate_label(label)
    when 2 then tube_label(label)
    else
      raise StandardError, "Unknown printer layout #{@layout}"
    end
  end

  def payload
    {
      data: {
        type: 'print_jobs',
        attributes: {
          printer_name: @printer,
          label_template_id: label_id,
          labels: {
            body: @labels.map { |label| convert_label(label) }
          }
        }
      }
    }.to_json
  end

  def date
    Time.zone.today.strftime('%d-%b-%Y')
  end
end
