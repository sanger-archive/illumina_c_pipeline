module Presenters
  module Statemachine
    module QcCompletable

      module QcCreatableStep
        def control_additional_creation(&block)
          yield unless default_child_purpose.nil?
          nil
        end

        def default_child_purpose
          labware.plate_purpose.children.detect {|purpose| Settings.qc_purposes.include?(purpose.name) }
        end
      end

      def self.included(base)
        base.class_eval do
          include Presenters::Statemachine::Shared

          state_machine :state, :initial => :pending do
            event :start do
              transition :pending => :started
            end

            event :take_default_path do
              transition :pending => :started
              transition :started => :passed
              transition :passed  => :qc_complete
            end

            event :pass do
              transition [ :pending, :started ] => :passed
            end

            event :qc_complete do
              transition :passed => :qc_complete
            end

            state :passed do
              include QcCreatableStep
            end

            state :qc_complete, :human_name => 'QC Complete' do
              # Nope, we create the tubes in the state changer

              def default_child_purpose
                labware.plate_purpose.children.detect {|purpose| ! Settings.qc_purposes.include?(purpose.name) }
              end
            end

            event :fail do
              transition [ :passed ] => :failed
            end

            event :cancel do
              transition [ :pending, :started, :passed, :qc_complete ] => :cancelled
            end
          end
        end
      end
    end
  end
end
