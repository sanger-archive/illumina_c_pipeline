require 'rails_helper'
require './app/controllers/tag_plates_controller'

describe TagPlatesController, type: :controller do

  let(:qcable_json) { JSON.parse(assigns(:qcable).to_json) }
  let(:expected_json) {{
        "asset_uuid" => "tag2-tube-uuid",
        "lot_number" => "lot1",
        "qcable_type" => "Tag 2 Tube",
        "state" => "available",
        "tag_layout" => "Tag 502 (ATAGAGGC)",
        "template_uuid" => "tag-2-template-uuid",
        "type" => "Tag 2 Tubes",
        "uuid" => "tag2-qcable-uuid"
  }}

  describe "GET" do

    has_a_working_api
    stub_request_and_response('tag2-qcable-uuid')
    stub_request_and_response('tag2-lot-uuid')
    stub_request_and_response('lot-type-uuid')

    it 'provides information about the tag plate' do
      get :show, id: 'tag2-qcable-uuid', format: :json
      expect(assigns(:qcable)).to be_a Presenters::QcablePresenter
      expect(qcable_json).to eq(expected_json)
    end
  end

end
