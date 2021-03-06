# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Creating a new inventory", type: :system do
  after :all do
    clean_up!
  end

  context "when visiting the page as" do

    it "anon users redirects to sign_in page" do
      visit new_inventory_path

      expect(page).to have_content "You need to sign in first"
      expect(page).to have_content "Sign in"
    end

    it "builders redirects to home page" do
      sign_in FactoryBot.create(:user)

      visit new_inventory_path

      expect(page).to have_content "You don't have permission"
      expect(page).to have_content "Upcoming Builds"
    end

    it "leaders redirects to home page" do
      sign_in FactoryBot.create(:leader)

      visit new_inventory_path

      expect(page).to have_content "You don't have permission"
      expect(page).to have_content "Upcoming Builds"
    end

    it "inventory users shows the page" do
      sign_in FactoryBot.create(:user, does_inventory: true)
      visit new_inventory_path

      expect(page).to have_content "Create a new inventory"
    end

    it "users who receive inventory emails shows the page" do
      sign_in FactoryBot.create(:user, send_inventory_emails: true)
      visit new_inventory_path

      expect(page).to have_content "Create a new inventory"
    end

    it "admins shows the page" do
      sign_in FactoryBot.create(:admin)
      visit new_inventory_path

      expect(page).to have_content "Create a new inventory"
      expect(page).to have_css("input#inventory_date")
      expect(page).to have_button "Create Inventory"
    end
  end

  context "when the URL has" do
    before :each do
      sign_in FactoryBot.create(:admin)
    end

    it "no parameter it establishes a manual inventory" do
      visit new_inventory_path
      expect(page).to have_css("input#inventory_manual[value='true']", visible: false)
      expect(page).to have_css("input#inventory_receiving[value='false']", visible: false)
      expect(page).to have_css("input#inventory_shipping[value='false']", visible: false)
    end

    it "?type=manual it establishes a manual inventory" do
      visit new_inventory_path(type: "manual")
      expect(page).to have_css("input#inventory_manual[value='true']", visible: false)
      expect(page).to have_css("input#inventory_receiving[value='false']", visible: false)
      expect(page).to have_css("input#inventory_shipping[value='false']", visible: false)
    end

    it "?type=receiving it establishes a receiving inventory" do
      visit new_inventory_path(type: "receiving")
      expect(page).to have_css("input#inventory_manual[value='false']", visible: false)
      expect(page).to have_css("input#inventory_receiving[value='true']", visible: false)
      expect(page).to have_css("input#inventory_shipping[value='false']", visible: false)
    end

    it "?type=shipping it establishes a shipping inventory" do
      visit new_inventory_path(type: "shipping")
      expect(page).to have_css("input#inventory_manual[value='false']", visible: false)
      expect(page).to have_css("input#inventory_receiving[value='false']", visible: false)
      expect(page).to have_css("input#inventory_shipping[value='true']", visible: false)
    end
  end

  context "when a conflicting inventory exists" do
    it "isn't possible" do
      FactoryBot.create(:inventory)
      sign_in FactoryBot.create(:admin)
      visit new_inventory_path

      first_count = Inventory.all.count

      click_button "Create Inventory"

      expect(page).to have_content "A manual inventory already exists for"
      expect(page).to have_content("Current Inventory:")

      second_count = Inventory.all.count

      expect(second_count).to eq first_count
    end
  end

  context "when there's no conflicting inventory" do
    it "is possible" do
      sign_in FactoryBot.create(:admin)
      visit new_inventory_path

      first_count = Inventory.all.count

      click_button "Create Inventory"

      expect(page).to have_content("The inventory has been created.")
      expect(page).to have_content("Current Inventory:")

      second_count = Inventory.all.count

      expect(second_count).to eq first_count + 1
    end
  end

end
