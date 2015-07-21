class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    # TODO: Check for duplicates.
    
    @user = User.new(user_params)

    if !@user.save
      render :new
      return
    end

    case(session[:pending_action])
    when 'create_pledge'
      session[:pending_pledge][:donor_id] = @user.id if !session[:pending_pledge].blank?
      binding.pry
      redirect_to process_pending_pledge_path
    else
      redirect_to root_path
    end
    
    session[:pending_action] = nil
  end

private

  def user_params
    begin
      params.require(:user)
        .permit(:first_name,
                :last_name,
                :phone_number,
                :email,
                :password,
                :password_confirmation)
    rescue ActionController::ParameterMissing => e
      logger.info "Failed to parse user params from #{params.inspect}"
      {}
    end
  end
end
