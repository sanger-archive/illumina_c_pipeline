require 'rails_helper'

RSpec.describe "Show metadata", type: :feature do

  describe "show" do

    has_a_working_api
    stub_request_and_response('process-metadatum-collection')

    it "shows metadata for a plate" do
      visit metadatum_path('process-metadatum-collection-uuid')
      expect(page).to have_content("Metadata")
      expect(page).to have_content("Key1: Value1 Key2: Value2 Key3: Value3")
    end

  end

  describe "#create", js: :true do

    has_a_working_api(3)
    stub_request_and_response('create-process-metadatum-collection')
    stub_request_and_response('process-metadatum-collection')

    it "can create process metadatum collection for a plate" do
      visit new_metadatum_path
      within('#metadatum1') do
        fill_in "metadata__key", with: "Key1"
        fill_in "metadata__value", with: "Value1"
      end
      click_link("Add metadatum")
      within('#metadatum2') do
        fill_in "metadata__key", with: "Key2"
        fill_in "metadata__value", with: "Value2"
      end
      click_link("Add metadatum")
      within('#metadatum3') do
        fill_in "metadata__key", with: "Key3"
        fill_in "metadata__value", with: "Value3"
      end
      click_button "Save"
      expect(page).to have_content("Metadata was added successfully")
    end

  end

end