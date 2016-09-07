require 'rails_helper'
require './app/models/forms/tagging_form'

describe Forms::TaggingForm do

  has_a_working_api
  # We retrieve the plate during initialization to set up the pools
  stub_request_and_response('ilc-stock-plate')
  # We retrieve the wells as part of this.
  stub_request_and_response('ilc-stock-plate-wells')

  context "On new" do
    let(:tagging_form) {
      Forms::TaggingForm.new(
        :purpose_uuid=>"ilc-al-libs-tagged-uuid",
        :parent_uuid=>"ilc-stock-plate-uuid",
        :api       => api
      )
    }

    it 'can be created' do
      expect(tagging_form).to be_a Forms::TaggingForm
    end

    context 'with purpose mocks' do
      stub_request_and_response('ilc-al-libs-tagged-uuid')
      it 'describes the child purpose' do
        expect(tagging_form.child_purpose.name).to eq('ILC AL Libs Tagged')
      end
    end

    # context 'with parent mocks' do
    #   it 'describes the parent barcode' do
    #     expect(presenter.labware.barcode.ean13).to eq('ilc-stock-plate-barcode')
    #   end
    # end

  end

  context "On create" do
    context "With no tag 2" do

      let(:tagging_form) {
        Forms::TaggingForm.new(
          :purpose_uuid=>"ilc-al-libs-tagged-uuid",
          :parent_uuid=>"ilc-stock-plate-uuid",
          :tag_group_uuid=>"tag-group-uuid",
          :walking_by=>"manual by plate",
          :direction=>"column",
          :offset=>"0",
          :tag_start=>"1",
          :api       => api,
          :user_uuid => "user-uuid"
        )
      }

      it 'can be created' do
        expect(tagging_form).to be_a Forms::TaggingForm
      end

      it 'renders the "tagging" page' do
        controller = CreationController.new
        expect(controller).to receive(:render).with('tagging')
        tagging_form.render(controller)
      end

      context 'on save!' do
        # Create the al-libs-tagged plate
        stub_request_and_response('plate-creation-ilc-al-libs-tagged')
        # Fetch the custom transfer template
        stub_request_and_response('custom-plate-transfer-template')
        # Then create a new transfer using it
        stub_request_and_response('custom-plate-transfer-to-ilc-al-libs-tagged')
        # Apply the tag-group to the whole plate with no offset, starting at 1.
        stub_request_and_response('tag-layout-creation-a')

        it 'creates a tag plate' do
          tagging_form.save!
        end

        it 'has the correct child (and uuid)' do
          tagging_form.save!
          expect(tagging_form.child.uuid).to eq('ilc-al-libs-tagged-plate-uuid')
        end
      end
    end

    context "With tag 2" do

      let(:tagging_form) {
        Forms::TaggingForm.new(
          :purpose_uuid=>"ilc-al-libs-tagged-uuid",
          :parent_uuid=>"ilc-stock-plate-uuid",
          :tag_group_uuid=>"tag-group-uuid",
          :walking_by=>"manual by plate",
          :direction=>"column",
          :offset=>"0",
          :tag_start=>"1",
          :api       => api,
          :user_uuid => "user-uuid",
          :tag2_tube_barcode => "tag2-tube-barcode",
          :tag2_tube => { :asset_uuid => "tag-2-tube-uuid", :template_uuid => "tag-2-template-uuid" }
        )
      }

      # We retrieve the plate during initialization to set up the pools
      stub_request_and_response('ilc-stock-plate')
      # We retrieve the wells as part of this.
      stub_request_and_response('ilc-stock-plate-wells')

      it 'can be created' do
        expect(tagging_form).to be_a Forms::TaggingForm
      end

      it 'renders the "tagging" page' do
        controller = CreationController.new
        expect(controller).to receive(:render).with('tagging')
        tagging_form.render(controller)
      end

      context 'on save!' do
        # Create the al-libs-tagged plate
        stub_request_and_response('plate-creation-ilc-al-libs-tagged')
        # Fetch the custom transfer template
        stub_request_and_response('custom-plate-transfer-template')
        # Then create a new transfer using it
        stub_request_and_response('custom-plate-transfer-to-ilc-al-libs-tagged')
        # Apply the tag-group to the whole plate with no offset, starting at 1.
        stub_request_and_response('tag-layout-creation-a')

        # Then do the tag 2 specific stuff

        # Flags the tag 2 tube as exhausted
        stub_request_and_response('state-change-tag-2-tube-to-exhausted')
        # Retrieves tag 2 template
        stub_request_and_response('tag-2-template-uuid')
        # Applies the tag 2 template
        stub_request_and_response('tag-2-template-layout-creation-a')

        it 'creates a tag plate' do
          tagging_form.save!
        end

        it 'has the correct child (and uuid)' do
          tagging_form.save!
          expect(tagging_form.child.uuid).to eq('ilc-al-libs-tagged-plate-uuid')
        end
      end
    end
  end
end
