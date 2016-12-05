module Presenters
  class QCTubePresenter < TubePresenter

    class_inheritable_reader    :authenticated_tab_states
    write_inheritable_attribute :authenticated_tab_states, {
        :pending     => [ 'labware-summary-button', 'labware-state-button', 'labware-metadata-button' ],
        :started     => [ 'labware-summary-button', 'labware-state-button', 'labware-metadata-button' ],
        :passed      => [ 'labware-summary-button', 'labware-state-button', 'labware-metadata-button' ],
        :cancelled   => [ 'labware-summary-button', 'labware-metadata-button' ],
        :failed      => [ 'labware-summary-button', 'labware-metadata-button' ]
    }

    write_inheritable_attribute :has_qc_data?, true

    def qc_owner
      labware
    end

    def control_additional_creation(&block)
      nil
    end

    state_machine :state, :initial => :pending do
      event :start do
        transition :pending => :started
      end

      event :take_default_path do
        transition :pending => :started
        transition :started => :passed
      end

      event :pass do
        transition [ :pending, :started ] => :passed
      end

      event :fail do
        transition [ :passed ] => :failed
      end

      event :cancel do
        transition [ :pending, :started ] => :cancelled
      end

      state :pending do
        include Statemachine::StateDoesNotAllowChildCreation
      end

      state :started do
        include Statemachine::StateDoesNotAllowChildCreation
      end

      state :passed do
        include Statemachine::StateDoesNotAllowChildCreation
      end

    end
  end
end
