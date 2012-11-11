require 'hydrant/workflow/steps/file_upload_step'

module Hydrant::Workflow::WorkflowControllerBehavior

  def create_workflow_step(name, *args)
    #name = name.underscore.camelize
    step = nil

    case name
    when 'file_upload'
      step = Hydrant::Workflow::Steps::FileUploadStep.new
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
    
    if @ingest_status.nil?
      @ingest_status = IngestStatus.find_or_create(pid: pid)
    else
      active_step = active_step || @ingest_status.current_step
      logger.debug "<< COMPLETED : #{@ingest_status.completed?(active_step)} >>"
      
      if HYDRANT_STEPS.last? active_step and @ingest_status.completed? active_step
        @ingest_status.publish
      end
      logger.debug "<< PUBLISHED : #{@ingest_status.published} >>"

      if @ingest_status.current?(active_step) and not @ingest_status.published
        logger.debug "<< ADVANCING to the next step in the workflow >>"
        logger.debug "<< #{active_step} >>"
        @ingest_status.current_step = @ingest_status.advance
      end
    end

    @ingest_status.save
    @ingest_status
  end

end

