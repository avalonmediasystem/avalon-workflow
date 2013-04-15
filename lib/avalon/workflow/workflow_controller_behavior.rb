module Avalon::Workflow::WorkflowControllerBehavior
  extend ActiveSupport::Concern

  included do
    before_filter :update_active_step, only: [:edit, :update]
  end

  def update_active_step
    #FIXME make this follow ||= pattern
    @active_step = params[:step] || model_object.workflow.last_completed_step.first
    @active_step = HYDRANT_STEPS.first.step if @active_step.blank?
  end

  def inject_workflow_steps
    @workflow_steps = HYDRANT_STEPS
  end

  def edit
    context = perform_step_action :before_step

    custom_edit #yield to custom_edit in the controller

    prev_step = HYDRANT_STEPS.previous(@active_step)
    unless prev_step.nil? || model_object.workflow.completed?(prev_step.step)
      redirect_to edit_polymorphic_path(model_object)
      return
    end
  end

  def custom_edit
  end

  def update
    context = perform_step_action :execute

    # yield to custom_update in the controller
    custom_update

    # move to the next step if object is valid
    if model_object.errors.empty? && params[:save_and_continue].present?
      model_object.workflow.update_status(@active_step)

      if HYDRANT_STEPS.has_next?(@active_step)
        @active_step = HYDRANT_STEPS.next(@active_step).step
      elsif model_object.workflow.published?
        @active_step = 'published'
      end
    end

    # if object has updated attributes and or the step has changed
    model_object.save(validate: false)

    respond_to do |format|
      format.html do 
        if model_object.errors.present?
          flash[:error] = 'There are errors with your submission. Please correct them before continuing.'
          render :edit
        elsif model_object.workflow.published? && model_object.workflow.current?(@active_step)
          redirect_to(polymorphic_path(model_object))
        else
          redirect_to(get_redirect_path(@active_step, model_object))
        end
      end
    end

  end

  def custom_update
  end

  def model_object
    @model_object ||= ActiveFedora::Base.find(params[:id], cast: true)
  end

  def build_context
    params.merge!({model_variable_name.to_sym => model_object, user: user_key})
  end

  def model_variable_name
    controller_name.classify.downcase
  end

  def perform_step_action action
    context = HYDRANT_STEPS.get_step(@active_step).send(action, build_context)
    context_to_instance_variables context
    context
  end

  protected

  def context_to_instance_variables context
    #copy everything out of context and into instance variables
    context.each {|k,v| self.instance_variable_set("@#{k}", v)}
  end 

  def get_redirect_path(target, obj)
    unless HYDRANT_STEPS.last?(params[:step]) && @active_step == "published"
      redirect_path = edit_polymorphic_path(obj, step: target)
    else
      flash[:notice] = "This resource is now available for use in the system"
      redirect_path = polymorphic_path(obj)
    end

    redirect_path
  end

end

