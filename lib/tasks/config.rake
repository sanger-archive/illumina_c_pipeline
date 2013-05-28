namespace :config do
  desc 'Generates a configuration file for the current Rails environment'

  require "#{Rails.root}/config/robots.rb"

  PLATE_PURPOSES = [
    'ILC Stock',
    'ILC AL Libs',
    'ILC Lib PCR',
    'ILC Lib PCR-XP ',
    'ILC AL Libs Tagged'
  ]

  QC_PLATE_PURPOSES = [

  ]

  TUBE_PURPOSES = [
    'ILC Lib Pool Norm'
  ]

  QC_TUBE_PURPOSES = [
    'ILC QC Pool'
  ]

  task :generate => :environment do
    api = Sequencescape::Api.new(IlluminaCPipeline::Application.config.api_connection_options)

    plate_purposes    = api.plate_purpose.all.select { |pp| PLATE_PURPOSES.include?(pp.name) }
    qc_plate_purposes = api.plate_purpose.all.select { |pp| QC_PLATE_PURPOSES.include?(pp.name) }
    tube_purposes     = api.tube_purpose.all.select  { |tp| TUBE_PURPOSES.include?(tp.name)  }
    qc_tube_purposes  = api.tube_purpose.all.select  { |tp| QC_TUBE_PURPOSES.include?(tp.name)  }

    barcode_printer_uuid = lambda do |printers|
      ->(printer_name){
        printers.detect { |prt| prt.name == printer_name}.try(:uuid) or
        raise "Printer #{printer_name}: not found!"
      }
    end.(api.barcode_printer.all)

    # Build the configuration file based on the server we are connected to.
    CONFIG = {}.tap do |configuration|

      configuration[:'large_insert_limit'] = 250

      configuration[:searches] = {}.tap do |searches|
        puts "Preparing searches ..."

        api.search.all.each do |search|
          searches[search.name] = search.uuid
        end
      end

      configuration[:transfer_templates] = {}.tap do |transfer_templates|
        puts "Preparing transfer templates ..."

        api.transfer_template.all.each do |transfer_template|
          transfer_templates[transfer_template.name] = transfer_template.uuid
        end
      end

      configuration[:purposes] = {}.tap do |labware_purposes|
        # Setup a hash that will enable us to lookup the form, presenter, and state changing classes
        # based on the name of the plate purpose.  We can then use that to generate the information for
        # the mapping from UUID.
        #
        # The inner block is laid out so that the class names align, not so it's readable!
        name_to_details = Hash.new do |h,k|
          h[k] = {
            :form_class           => 'Forms::CreationForm',
            :presenter_class      => 'Presenters::StandardPresenter',
            :state_changer_class  => 'StateChangers::DefaultStateChanger',
            :default_printer_uuid => barcode_printer_uuid.('g312bc2')
          }
        end.tap do |presenters|
          # Illumina-C plates

          presenters['ILC Stock'].merge!(

          )
          presenters['ILC AL Libs'].merge!(

          )
          presenters['ILC Lib PCR'].merge!(

          )
          presenters['ILC Lib PCR-XP '].merge!(

          )
          presenters['ILC AL Libs Tagged'].merge!(

          )
          presenters['ILC Lib Pool Norm'].merge!(

          )
          presenters['ILC QC Pool'].merge!(

          )

        end

        purpose_details_by_uuid = lambda { |labware_purposes, purpose|
          labware_purposes[purpose.uuid] = name_to_details[purpose.name].dup.merge(
            :name => purpose.name
          )
        }.curry.(labware_purposes)

        puts "Preparing plate purpose forms, presenters, and state changers ..."
        plate_purposes.each(&purpose_details_by_uuid)
        puts "Preparing QC plate purpose forms, presenters, and state changers ..."
        qc_plate_purposes.each(&purpose_details_by_uuid)

        puts "Preparing Tube purpose forms, presenters, and state changers ..."
        tube_purposes.each(&purpose_details_by_uuid)
        puts "Preparing QC Tube purpose forms, presenters, and state changers ..."
        qc_tube_purposes.each(&purpose_details_by_uuid)
      end



      configuration[:purpose_uuids] = {}.tap do |purpose_uuids|

        store_purpose_uuids = lambda { |purpose_uuids, purpose|
          purpose_uuids[purpose.name] = purpose.uuid
        }.curry.(purpose_uuids)

        tube_purposes.each(&store_purpose_uuids)
        plate_purposes.each(&store_purpose_uuids)
        qc_plate_purposes.each(&store_purpose_uuids)
      end

      configuration[:robots]      = ROBOT_CONFIG
      configuration[:locations]   = LOCATION_PIPELINES
      configuration[:qc_purposes] = QC_PLATE_PURPOSES

    end


    # Write out the current environment configuration file
    File.open(File.join(Rails.root, %w{config settings}, "#{Rails.env}.yml"), 'w') do |file|
      file.puts(CONFIG.to_yaml)
    end
  end

  task :default => :generate
end
