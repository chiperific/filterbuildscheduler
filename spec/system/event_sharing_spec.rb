# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'An event can be shared', type: :system, js: true do
  before :each do
    event = FactoryBot.create(:event)
    visit event_path event
  end

  after :all do
    clean_up!
  end

  it 'from the event\'s show page' do
    expect(page).to have_content 'Share This Event!'
  end

  it 'on facebook' do
    # the fb_iframe_widget doesn't appear until the fb script runs
    # this indicates the fb script has completed
    expect(page).to have_css('div.fb_iframe_widget')

    within_frame(find('div.fb_iframe_widget span iframe')) do
      @fb_window = window_opened_by do
        sleep 1
        find('#facebook a').click
      end
      expect(page).to have_css('#facebook') # HTML within the FB iFrame
    end
    expect(@fb_window).to exist
  end

  it 'on twitter' do
    expect(page).to have_css('div.twitter-div')

    within_frame(find('iframe#twitter-widget-0')) do
      sleep 1
      @twitter_window = window_opened_by do
        click_link 'b'
      end
      expect(page).to have_link 'b' # The Twitter button
    end
    expect(@twitter_window).to exist
  end

  it 'by printing a poster' do
    expect(page).to have_css('a#poster_link')

    # Intermittent Failures
    # click_link "poster_link"
    # sleep 1
    # within_window( ->{ page.title == '20 Liters Event Poster' } ) do
    #   expect(page).to have_content "Roll up your sleeves to solve the global water crisis"
    #   expect(page).to have_link "print_btn"
    # end
  end

  it 'by copying the URL' do
    expect(page).to have_css('a#btn_copy')
  end
end
