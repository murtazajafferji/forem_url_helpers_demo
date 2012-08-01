class ApplicationController < ActionController::Base

  def forem_user
    current_user
  end
  helper_method :forem_user

  protect_from_forgery
  
  private 
  # from Forem ApplicationController
  def authenticate_forem_user
    if !forem_user
      session["user_return_to"] = request.fullpath
      flash.alert = t("forem.errors.not_signed_in")
      redirect_to Forem.sign_in_path || main_app.sign_in_path
    end
  end

  def forem_admin?
    forem_user && forem_user.forem_admin?
  end
  helper_method :forem_admin?

  def forem_admin_or_moderator?(forum)
    forem_user && (forem_user.forem_admin? || forum.moderator?(forem_user))
  end
  helper_method :forem_admin_or_moderator?
  
  
  # from Forem TopicsController
  def find_forum
    @forum = Forem::Forum.find_by_id(params[:forum_id]) #changed this line
    @forum = Forem::Forum.find_or_create_by_title("Dr. K") if @forum.blank? #added this line
    authorize! :read, @forum
  end

  def find_topic
    begin
      scope = forem_admin_or_moderator?(@forum) ? @forum.topics : @forum.topics.visible.approved_or_pending_review_for(forem_user)
      @topic = scope.find(params[:id])
      authorize! :read, @topic
    rescue ActiveRecord::RecordNotFound
      flash.alert = t("forem.topic.not_found")
      redirect_to @forum and return
    end
  end

  def register_view
    @topic.register_view_by(forem_user)
  end

  def block_spammers
    if forem_user.forem_state == "spam"
      flash[:alert] = t('forem.general.flagged_for_spam') + ' ' + t('forem.general.cannot_create_topic')
      redirect_to :back
    end
  end
end
