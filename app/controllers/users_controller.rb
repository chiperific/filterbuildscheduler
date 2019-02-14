# frozen_string_literal: true

class UsersController < ApplicationController

  before_action :find_and_authorize_user, only: [:show, :edit, :update, :delete]

  def show
    if @user.has_no_password
      flash[:warning] = "You haven't set your password yet, please do so now."
    end

    @leading_events = @user.registrations
                           .where(leader: true)
                           .joins(:event)
                           .where('events.end_time > ?', Time.now)
                           .map(&:event)
    @attending_events = @user.registrations
                             .where(leader: false)
                             .joins(:event)
                             .where('events.end_time > ?', Time.now)
                             .map(&:event)
    @lead_events = @user.registrations
                        .where(leader: true)
                        .joins(:event)
                        .where('events.end_time < ?', Time.now)
                        .map(&:event)
    @attended_events = @user.registrations
                            .where(leader: false)
                            .joins(:event)
                            .where('events.end_time < ?', Time.now)
                            .map(&:event)
  end

  def edit
    if @user.has_no_password
      flash[:warning] = "You haven't set your password yet, please do so now."
    end
  end

  def update
    if @user.valid_password?(params[:user][:password])
      modified_params = user_params_no_pws
    else
      modified_params = user_params
    end

    if @user.update(modified_params)
      flash[:success] = "Info updated!"
      if modified_params[:password].present?
        DeviseMailer.password_change(@user).deliver!
      end
      redirect_to show_user_path @user
    else
      render 'edit'
    end
  end

  def delete
    @user.delete
    flash[:danger] = "User deleted"
    redirect_to users_path
  end

  def communication
    # filter out users with no registrations by joining
    authorize @users = User.builders.joins(:registrations).group('users.id').order('users.created_at DESC')

    @cancelled_events = Event.only_deleted
    @closed_events = Event.closed

    @finder = "communication"
  end

  def comm_complete
    @user_ids = params[:user_ids]

    if @user_ids.present?
      User.find(@user_ids).each do |u|
        u.email_opt_out = true
        u.save
      end
    end

    redirect_to users_communication_path
  end

  private

  def find_and_authorize_user
    @user = User.find params[:id]
    authorize @user
  end

  def user_params
    params.require(:user).permit :fname,
                                  :lname,
                                  :email,
                                  :phone,
                                  :email_opt_out,
                                  :password,
                                  :password_confirmation
  end

  def user_params_no_pws
    params.require(:user).permit :fname,
                                  :lname,
                                  :email,
                                  :phone,
                                  :email_opt_out
  end

end
