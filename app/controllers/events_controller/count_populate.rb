# frozen_string_literal: true

class EventsController
  class CountPopulate
    # Based upon the tech built at the event, it adds the number of loose and boxed items to the appropriate component
    def initialize(loose, box, event, inventory, user_id)
      @loose = loose
      @box = box
      @event = event
      @inventory = inventory
      @technology = @event.technology
      @user_id = user_id

      # If there's no primary component, just bail
      return unless @technology.primary_component.present? 
      
      # Find the component that represents the completed technology
      @tech_component = @technology.primary_component

      # Find that component among the counts
      @count_component = @inventory.counts.where(component_id: @tech_component.id).first_or_initialize

      # If the loose value is nil or it matches the current value, do nothing
      if @loose != nil && @count_component.diff_from_previous("loose") != @loose
        @count_component.loose_count += @loose
      end

      # If the box value is nil or it matches the current value, do nothing
      if @box != nil && @count_component.diff_from_previous("box") != @box
        @count_component.unopened_boxes_count += @box
      end

      @count_component.user_id = @user_id
      @count_component.save 
    end
  end
end
