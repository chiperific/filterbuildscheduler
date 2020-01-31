# README

## Things to do
0.0 `events/:id/lead` needs phone #s and business hours vs after-hours flags for leaders

0.1 Needs an email leaders function:
`email leaders: x business hours x after-hours x both [email]`

0.3 NEXT PRODUCTION RELEASE:
- `Technology.all.each { |tech| tech.update(short_name: tech.short_name_calc )}`
- `Technology.find(5).update(short_name: 'No Filter')`
- `User.leaders.update_all(available_after_hours: true, available_business_hours: false)`

1. .env, secrets.yml, credentials.yml.enc <--- combine
- .env: look for ENV.fetch
- secrets.yml: check .gitignore; search for use of secret_key_base
- should be using master.key && credentials.yml.enc EXCLUSIVELY, even in Heroku (by seeting )

2. I created EventsController::SubtractSubsets and should write tests for it
  * Test the class (as a model)
  * Write a system test for event-based inventories
  ** The inventory gets counts (EventsController::CountPopulate)
  ** The inventory gets the results added to the apropriate counts (InventoriesController::CountUpdate)
  ** The inventory gets subsets of components subtracted (EventsController::SubtractSubsets)
  ** The inventory gets extrapolations (InventoriesController::Extrapolate)

3. Notify us if someone important in Kindful registers for an event
- https://developer.kindful.com/customer/querying-guide/contact-queries#retrieve
- Managed donor group: 26572
- If yes, send an email to Amanda & Chip with a calendar appointment for the event.

4. Part has_one material (instead of has_many)

5. Inventory#create: ability to mark some technologies as "unchanged" which would auto-carry the previous value and mark them as counted.

## HMMM
1. `weeks_to_out` and `per_technology` rely on lots of `.first`s which is an issue for items that `have_many` technologies
- Part#technology
- Material#technology
- Component#technologies
2. Tech Status sux big ones and needs some work (the 4-level deep problem)
3. EventsController::SubtractSubsets.subtract! only goes 1 level deep.

## Remind myself:
1. production backup / development restore-from production
  - `User.first.update(password: "password", password_confirmation: "password")`
2. `Record.only_deleted.each do |record| record.really_destroy! end`
3. `orphans = User.builders.left_outer_joins(:registrations).where(registrations: { id: nil })`


## Data cleanup:
1. Inventory data:
- `invs = Inventory.where('date < ?', '2019-11-01')`
- `invs.each { |inv| inv.really_destroy! }`
2. Parts/Materials/Components (dependent: :destroy):
- `mats = Material.only_deleted`
- `mats.each { |m| m.really_destroy! }`
3. Events/Registrations
4. Users
5. Delayed::Job:
- `production run rails jobs:clear`
