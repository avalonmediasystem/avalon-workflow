module Hydrant::Workflow::WorkflowControllerBehavior

  def inject_workflow_steps
    logger.debug "<< Injecting the workflow into the view >>"
    @workflow_steps = HYDRANT_STEPS
  end

end

