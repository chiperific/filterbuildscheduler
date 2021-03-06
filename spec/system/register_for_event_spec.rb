# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Register for Event', type: :system do
  let(:event) { create :event }

  after :all do
    clean_up!
  end

  context 'logged in user' do
    context 'shows the registration_signedin partial' do
      it 'without leader checkbox for a builder' do
        user = FactoryBot.create(:user)
        sign_in user
        visit event_path event

        expect(page).to have_content event.full_title
        expect(page).to have_content user.name
        expect(page).to have_field 'registration_accept_waiver'
        expect(page).to have_css("input[name='commit']")

        expect(page).to_not have_field 'registration_user_fname'
        expect(page).to_not have_field 'registration_leader'
      end

      it 'with leader checkbox for a qualified leader' do
        user = FactoryBot.create(:leader)
        sign_in user
        user.technologies << event.technology
        user.save
        visit event_path event

        expect(page).to have_content event.full_title
        expect(page).to have_content user.name
        expect(page).to have_field 'registration_accept_waiver'
        expect(page).to have_field 'registration_leader'
        expect(page).to have_css("input[name='commit']")
      end
    end

    context 'can be filled out and submitted' do
      it 'to register a builder and send an email' do
        user = FactoryBot.create(:user)
        sign_in user
        visit event_path event

        check 'registration_accept_waiver'

        first_count = Delayed::Job.count

        click_submit

        expect(page).to have_content 'Registration successful!'
        expect(page).to have_content user.name
        expect(page).to have_link 'Change/Cancel Registration'

        second_count = Delayed::Job.count
        expect(second_count).to eq first_count + 1
      end

      it 'to register a leader and send an email' do
        user = FactoryBot.create(:leader)
        sign_in user
        user.technologies << event.technology
        user.save
        visit event_path event

        check 'registration_accept_waiver'
        check 'registration_leader'

        first_count = Delayed::Job.count

        click_submit

        expect(page).to have_content 'Registration successful!'
        expect(page).to have_content user.name
        expect(page).to have_link 'Change/Cancel Registration'
        expect(page).to have_content 'You are the only leader currently registered.'

        second_count = Delayed::Job.count
        expect(second_count).to eq first_count + 1
      end
    end
  end

  context 'when anon user' do
    before :each do
      visit event_path event
    end

    it 'shows the registration_anonymous partial' do
      expect(page).to have_content event.full_title

      expect(page).to have_field 'registration_user_fname'
      expect(page).to have_field 'registration_accept_waiver'
      expect(page).to have_css("input[name='commit']")
      expect(page).to_not have_field 'registration_leader'
    end

    it 'can be filled out and submitted, which sends the user\'s info to Kindful' do
      user = FactoryBot.build(:user)

      fill_in 'registration_user_fname', with: user.fname
      fill_in 'registration_user_lname', with: user.lname
      fill_in 'registration_user_email', with: user.email
      check 'registration_accept_waiver'

      expect_any_instance_of(KindfulClient).to receive(:import_user)

      click_submit

      expect(User.last.fname).to eq user.fname

      expect(page).to have_content 'Registration successful!'
      expect(page).to have_content user.name
      expect(page).to have_link 'Change/Cancel Registration'
    end

    it 'can be filled out using an existing email' do
      user = FactoryBot.create(:user)

      fill_in 'registration_user_email', with: user.email
      check 'registration_accept_waiver'

      click_submit

      expect(page).to have_content 'Registration successful!'
      expect(page).to have_content user.name
      expect(page).to have_link 'Change/Cancel Registration'
    end

    it 'has a modal for the waiver, which checks the box', js: true, retry: 6 do
      expect(page).to have_unchecked_field('registration_accept_waiver')

      click_on 'waiver_click'

      within('#waiverModal') do
        expect(page).to have_content 'Waiver of Liability'

        click_on 'Accept'
      end

      # expect(page).to have_content event.title
      sleep(6)
      expect(page).to have_checked_field('registration_accept_waiver')
    end
  end

  context 'admin registering someone else' do
    before(:each) do
      admin = FactoryBot.create(:admin)
      sign_in admin
      visit new_event_registration_path event
    end

    it 'shows the standard registration form' do
      expect(page).to have_content 'Register someone for ' + event.full_title
      expect(page).to have_field 'registration_user_fname'
      expect(page).to have_field 'registration_leader'
      expect(page).to have_css("input[name='commit']")
    end

    context 'can be filled out and submitted' do
      it 'using the Create & New button' do
        user = FactoryBot.build(:user)

        fill_in 'registration_user_email', with: user.email
        fill_in 'registration_user_fname', with: user.fname
        fill_in 'registration_user_lname', with: user.lname
        check 'registration_user_email_opt_out'

        click_button 'Create & New'

        expect(page).to have_content 'Registration successful!'
        expect(page).to have_content 'Register someone for ' + event.full_title
        expect(page).to have_field 'registration_user_fname'

        saved_user = User.find_by(email: user.email)

        expect(saved_user.email_opt_out).to eq true
      end

      it 'by email only for a user that exists', js: true do
        user = FactoryBot.create(:user)

        fill_in 'registration_user_email', with: user.email

        first_count = Delayed::Job.count

        click_submit

        leader_tbl_text = page.all('table#leaders_tbl td').map(&:text)
        builder_tbl_text = page.all('table#builders_tbl td').map(&:text)

        expect(page).to have_content 'Registrations for ' + event.full_title
        expect(leader_tbl_text).to eq ['No data available in table']
        expect(builder_tbl_text).to have_content user.name

        second_count = Delayed::Job.count
        expect(second_count).to eq first_count + 1
      end

      context 'for a new user' do
        let(:user) { build :user }

        it 'with email only isn\'t successful' do
          fill_in 'registration_user_email', with: user.email
          click_submit

          expect(page).to have_content 'First Name can\'t be blank | Last Name can\'t be blank'
          expect(page).to have_content 'Register someone for ' + event.full_title
          expect(page).to have_css('input[name="commit"]')
        end

        it 'with all fields is successful, which sends the user\'s info to Kindful' do
          fill_in 'registration_user_email', with: user.email
          fill_in 'registration_user_fname', with: user.fname
          fill_in 'registration_user_lname', with: user.lname

          first_count = Delayed::Job.count

          expect_any_instance_of(KindfulClient).to receive(:import_user)

          click_submit

          builder_tbl_text = page.all('table#builders_tbl td').map(&:text)

          expect(page).to have_content 'Registrations for ' + event.full_title
          expect(builder_tbl_text).to have_content user.name

          expect(User.last.email).to eq user.email

          second_count = Delayed::Job.count
          expect(second_count).to eq first_count + 1
        end
      end

      it 'to assign leaders if the user is a leader', js: true do
        user = FactoryBot.create(:leader)
        user.technologies << event.technology
        user.save

        fill_in 'registration_user_email', with: user.email
        check 'registration_leader'

        first_count = Delayed::Job.count

        click_submit

        leader_tbl_text = page.all('table#leaders_tbl td').map(&:text)
        builder_tbl_text = page.all('table#builders_tbl td').map(&:text)

        expect(page).to have_content 'Registrations for ' + event.full_title
        expect(builder_tbl_text).to eq ['No data available in table']
        expect(leader_tbl_text).to have_content user.name

        second_count = Delayed::Job.count
        expect(second_count).to eq first_count + 1
      end
    end
  end
end
