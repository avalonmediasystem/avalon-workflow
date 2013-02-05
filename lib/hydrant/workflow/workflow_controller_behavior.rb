module Hydrant::Workflow::WorkflowControllerBehavior

  def inject_workflow_steps
    @workflow_steps = HYDRANT_STEPS
  end

  def edit
    model_object = self.instance_variable_set("@#{controller_name.classify.downcase}", ActiveFedora::Base.find(params[:id], cast: true))

    @active_step = params[:step] || model_object.workflow.last_completed_step.first
    @active_step = HYDRANT_STEPS.first.step if @active_step.blank?
    prev_step = HYDRANT_STEPS.previous(@active_step)
    context = params.merge!({controller_name.classify.downcase.to_sym => model_object})
    context = HYDRANT_STEPS.get_step(@active_step).before_step context

    #copy everything out of context and into instance variables
    context.each {|k,v| self.instance_variable_set("@#{k}", v)}

    custom_edit #yield to custom_edit in the controller

    unless prev_step.nil? || model_object.workflow.completed?(prev_step.step)
      redirect_to edit_polymorphic_path(model_object)
      return
    end
  end

  def custom_edit
  end

  def update

    model_object = self.instance_variable_set("@#{controller_name.classify.downcase}", ActiveFedora::Base.find(params[:id], cast: true))

    @active_step = params[:step] || model_object.workflow.last_completed_step.first
    @active_step = HYDRANT_STEPS.first.step if @active_step.blank?
    prev_step = HYDRANT_STEPS.previous(@active_step)
    context = params.merge!({controller_name.classify.downcase.to_sym => model_object, user: user_key})
    context = HYDRANT_STEPS.get_step(@active_step).execute context

    #copy everything out of context and into instance variables
    context.each {|k,v| self.instance_variable_set("@#{k}", v)}

    custom_update #yield to custom_update in the controller

    unless model_object.errors.empty?
      report_errors model_object
    else
      if params[:commit] == "save_and_continue"
        model_object.workflow.update_status(@active_step)
        model_object.save(validate: false)

	# Advance to the next step
        if HYDRANT_STEPS.has_next?(@active_step)
          @active_step = HYDRANT_STEPS.next(@active_step).step
        elsif model_object.workflow.published?
          @active_step = "published"
        end
      end
      respond_to do |format|
        format.html { (model_object.workflow.published? and model_object.workflow.current?(@active_step)) ? redirect_to(polymorphic_path(model_object)) : redirect_to(get_redirect_path(@active_step, model_object)) }
        format.json { render :json => nil }
      end
    end
  end

  def custom_update
  end

  protected

  def get_redirect_path(target, model_object)
    unless HYDRANT_STEPS.last?(params[:step]) && @active_step == "published"
      redirect_path = edit_polymorphic_path(model_object, step: target)
    else
      flash[:notice] = "This resource is now available for use in the system"
      redirect_path = polymorphic_path(model_object)
    end

    redirect_path
  end

  def report_errors(model_object)
    flash[:error] = "There are errors with your submission. Please correct them before continuing."
    #XXX is this next line supposed to be HYDRANT_STEPS.first.step or active_step or what?!?
    step = params[:step] || HYDRANT_STEPS.first.template
    render :edit and return
  end

end

