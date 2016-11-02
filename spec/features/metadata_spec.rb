require 'rails_helper'

RSpec.describe "Show metadata in labware tab", type: :feature do

  describe 'creates metadata if plate does not have one', js: :true do

    has_a_working_api(5)
    stub_request_and_response('find-user-by-swipecard-uuid')
    stub_request_and_response('find-user-by-swipecard-first')
    stub_request_and_response('find-assets-by-barcode-uuid')
    stub_request_and_response('find-assets-by-barcode-first-ilc-stock-plate')
    stub_request_and_response('ilc-stock-plate')
    stub_request_and_response('ilc-stock-plate-wells')
    stub_request_and_response('barcode-printers', 2)
    stub_request_and_response('ilc-stock-plate-comments')
    stub_request_and_response('ilc-al-libs-uuid', 6)
    stub_request_and_response('create-process-metadatum-collection')
    stub_request_and_response('ilc-stock-plate-with-metadata')
    stub_request_and_response('ilc-stock-plate-with-metadata-wells')
    stub_request_and_response('process-metadatum-collection')
    stub_request_and_response('ilc-stock-plate-with-metadata-comments')

    Settings.searches['Find user by swipecard code'] = 'find-user-by-swipecard-uuid'
    Settings.searches['Find assets by barcode'] = 'find-assets-by-barcode-uuid'
    Settings.purposes['ilc-stock-plate-purpose-uuid'] = {name: 'ILC Stock'}
    Settings.purposes['ilc-stock-plate-purpose-uuid']= {presenter_class: 'Presenters::StockPlatePresenter'}
    Settings.large_insert_limit = 250
    Settings.request_types["Illumina-C Library Creation PCR"] = [ 'ILC AL Libs', true]
    Settings.purpose_uuids['ILC AL Libs'] = 'ilc-al-libs-uuid'

    it "creates new metadata and shows it on page", js: :true do

      visit search_path
      fill_in 'User Swipecard:', with: 'abcdef'
      fill_in 'Plate or Tube Barcode:', :with => '1111111111111'
      find('.plate-barcode').native.send_key(:Enter)
      expect(page).to have_content('Plate')
      expect(page).to have_content("Metadata")

      click_link("Metadata")

      within('.metadata') do
        expect(all('div[id^=metadatum]').count).to eq 0
      end

      click_link("Add metadatum")
      within('#metadatum1') do
        #the element is visible but capybara does not see it (jquery mobile selectmenu() not run?)
        select 'Key1', from: 'metadata__key__1', visible: false
        fill_in "metadata__value", with: "Value1"
      end
      click_link("Add metadatum")
      within('#metadatum2') do
        select 'Key2', from: 'metadata__key__2', visible: false
        fill_in "metadata__value", with: "Value2"
      end
      click_link("Add metadatum")
      within('#metadatum3') do
        select 'Key3', from: 'metadata__key__3', visible: false
        fill_in "metadata__value", with: "Value3"
      end

      first('input#asset_id', visible: false).set "ilc-stock-plate-with-metadata-uuid"
      first('input#path', visible: false).set "/illumina_c_plates/ilc-stock-plate-with-metadata-uuid"


      click_button "Save"
      expect(page).to have_content("Metadata was added successfully")
      expect(current_path).to eq illumina_c_plate_path('ilc-stock-plate-with-metadata-uuid')

      click_link("Metadata")
      within('.metadata') do
        expect(all('div[id^=metadatum]').count).to eq 3
      end

    end

  end

end