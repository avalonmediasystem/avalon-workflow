require 'hydrant/workflow/steps/file_upload_step'
require 'hydrant/workflow/steps/resource_description_step'
require 'hydrant/workflow/steps/structure_step'
require 'hydrant/workflow/steps/access_control_step'
require 'hydrant/workflow/steps/preview_step'

module Hydrant::Workflow::WorkflowControllerBehavior

  def create_workflow_step(name, *args)
    step = nil

    case name
      when 'file_upload'
        step = Hydrant::Workflow::Steps::FileUploadStep.new
      when 'resource-description'
	step = Hydrant::Workflow::Steps::ResourceDescriptionStep.new
      when 'structure'
	step = Hydrant::Workflow::Steps::StructureStep.new
      when 'access-control'
	step = Hydrant::Workflow::Steps::AccessControlStep.new
      when 'preview'
	step = Hydrant::Workflow::Steps::PreviewStep.new
      end

    step
  end

  def inject_workflow_steps
    logger.debug "<< Injecting the workflow into the view >>"
    @workflow_steps = HYDRANT_STEPS
  end
  
  def update_ingest_status(pid, active_step=nil)
    logger.debug "<< UPDATE_INGEST_STATUS >>"
    logger.debug "<< Updating current ingest step >>"
    
      active_step = active_step || @mediaobject.workflow.last_completed_step
      logger.debug "<< COMPLETED : #{@mediaobject.workflow.completed?(active_step)} >>"
      
      if HYDRANT_STEPS.last? active_step and @mediaobject.workflow.completed? active_step
        @mediaobject.workflow.publish
      end
      logger.debug "<< PUBLISHED : #{@mediaobject.workflow.published?} >>"

      if @mediaobject.workflow.current?(active_step) and not @mediaobject.workflow.published?
        logger.debug "<< ADVANCING to the next step in the workflow >>"
        logger.debug "<< #{active_step} >>"
        @mediaobject.workflow.last_completed_step = @mediaobject.workflow.advance
      end
  end

end

