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
      fill_in "Key", with: "Key1"
      fill_in "Value", with: "Value1"
      # click_link("Add metadata")
      # fill_in "Key", with: "Key2"
      # fill_in "Value", with: "Value2"
      # click_link("Add metadata")
      # fill_in "Key", with: "Key3"
      # fill_in "Value", with: "Value3"
      click_button "Save"
      expect(page).to have_content("Metadata was added successfully")
    end

  end

end