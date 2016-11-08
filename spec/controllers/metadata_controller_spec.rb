require 'rails_helper'
require './app/controllers/metadata_controller'

describe MetadataController, type: :controller do

  describe 'CREATE' do

    describe 'create' do

      has_a_working_api
      stub_request_and_response('create-custom-metadatum-collection')

      it 'creates metadata' do
        request.env['HTTP_REFERER'] = illumina_c_plate_path('ilc-stock-plate-uuid')
        post :create, {"metadata"=>[{"key"=>"Key1", "value"=>""}, {"key"=>"Key1", "value"=>"Value1"}, {"key"=>"Key2", "value"=>"Value2"}, {"key"=>"Key3", "value"=>"Value3"}],
                      "asset_id"=>"ilc-stock-plate-uuid"},  user_uuid: "user-uuid", format: :json
        expect(response).to redirect_to(illumina_c_plate_path('ilc-stock-plate-uuid'))
      end

    end
  end

  describe 'UPDATE' do

    describe 'add' do

      has_a_working_api
      stub_request_and_response('custom-metadatum-collection')
      stub_request_and_response('ilc-stock-plate-with-metadata')
      stub_request_and_response('user')
      stub_request_and_response('update-custom-metadatum-collection')

      it 'adds metadata' do
        request.env['HTTP_REFERER'] = illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid')
        put :update, id: "custom-metadatum-collection-uuid", "metadata"=>[{"key"=>"Key1", "value"=>""}, {"key"=>"Key1", "value"=>"Value1"}, {"key"=>"Key2", "value"=>"Value2"}, {"key"=>"Key3", "value"=>"Value3"}, {"key"=>"Key4", "value"=>"Value4"}],
                                                              "asset_id"=>"ilc-stock-plate-with-metadata-uuid"
        expect(response).to redirect_to(illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid'))
      end

    end

    describe 'remove' do

      has_a_working_api
      stub_request_and_response('custom-metadatum-collection-2')
      stub_request_and_response('ilc-stock-plate-with-metadata')
      stub_request_and_response('user')
      stub_request_and_response('update-custom-metadatum-collection-2')

      it 'removes metadata' do
        request.env['HTTP_REFERER'] = illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid')
        put :update, id: "custom-metadatum-collection-2-uuid", "metadata"=>[{"key"=>"Key1", "value"=>""}, {"key"=>"Key1", "value"=>"Value1"}, {"key"=>"Key3", "value"=>"Value3"}],
                                                                "asset_id"=>"ilc-stock-plate-with-metadata-uuid"
        expect(response).to redirect_to(illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid'))
      end

    end

    describe 'update' do

      has_a_working_api
      stub_request_and_response('custom-metadatum-collection-3')
      stub_request_and_response('ilc-stock-plate-with-metadata')
      stub_request_and_response('user')
      stub_request_and_response('update-custom-metadatum-collection-3')

      it 'updates metadata' do
        request.env['HTTP_REFERER'] = illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid')
        put :update, id: "custom-metadatum-collection-3-uuid", "metadata"=>[{"key"=>"Key1", "value"=>""}, {"key"=>"Key1", "value"=>"Value1"}, {"key"=>"Key2", "value"=>"Value4"}, {"key"=>"Key3", "value"=>"Value3"}],
                                                                "asset_id"=>"ilc-stock-plate-with-metadata-uuid"
        expect(response).to redirect_to(illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid'))
      end

    end
  end
end
