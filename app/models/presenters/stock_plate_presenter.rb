module Presenters
  class StockPlatePresenter < PlatePresenter
    include Presenters::Statemachine

    write_inheritable_attribute :authenticated_tab_states, {
        :pending    =>  [ 'labware-summary-button', 'labware-metadata-button' ],
        :started    =>  [ 'labware-summary-button', 'labware-metadata-button' ],
        :passed     =>  [ 'labware-creation-button','labware-summary-button', 'labware-metadata-button', 'well-failing-button' ],
        :cancelled  =>  [ 'labware-summary-button', 'labware-metadata-button' ],
        :failed     =>  [ 'labware-summary-button', 'labware-metadata-button' ]
    }

    def default_child_purpose
      child_name = Settings.request_types[labware.pools.values.first['request_type']].first
      api.plate_purpose.find(Settings.purpose_uuids[child_name])
    end

    def control_state_change(&block)
      # You cannot change the state of the stock plate
    end

    def control_worksheet_printing(&block)
      # you shouldn't be able to print a worksheet for a stock plate
      # either...
    end
  end
end
