# frozen_string_literal: true

class RegistrationReminderJob < ApplicationJob
  queue_as :registration_reminder

  def perform(*_args)
    puts '-+ Creating registration reminders'
    events = Event.pre_reminders.future.within_days(2)

    events.each do |e|
      EventMailer.remind_admins(e).deliver_now
      puts '-+-+ Admin reminder emails scheduled'
      e.registrations.pre_reminders.each do |r|
        RegistrationMailer.reminder(r).deliver_now
        r.update(reminder_sent_at: Time.zone.now)
      end
      puts '-+-+ ' + e.registrations.count.to_s + ' registration reminder email(s) sent'

      puts '-+-+ No registrations for ' + e.full_title if e.registrations.count < 1

      e.update(reminder_sent_at: Time.zone.now)
    end

    puts '-+-+ No events meet criteria' if events.count < 1

    puts '-+ Done creating'
  end
end
