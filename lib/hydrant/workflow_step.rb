# workflow_step.rb
#
# This template lays out the API for implementing your own custom steps. As a
# class it should never be used since its own implementations are trivial at
# best (unless you need a NoOp operation)
#
# Workflow state is designed to be chained so that multiple operations can be
# performed in sequence. Make sure that your own steps return the modified
# application context for use by methods down the line
module Hydrant
   module Workflow
      class WorkflowStep
	 # before_step will execute to set the context for an operation.
	 # If you need to load options for forms, verify MD5 checksums, or
	 # other similar functions this is the place to perform those
	 # calls 
	 #
	 # This method is analogous to the processing that would take place
	 # within the edit step of a controller to set up the view and
	 # environment for users
	 def before_step context
	    context
	 end

	 # after_step does the same except that it will fire once a step's
	 # perform method has finished. Example implementations here might
	 # include moving files, cleaning up and validating metadata, or
	 # rewinding the current step if it should not advance
	 def after_step context
	    context
	 end

	 # execute should take care of the actual events that need to happen
	 # when an operation is triggered. The context object which is passed
	 # should provide all the necessary information for the step. Any
	 # changes should be pushed out through the context object.
	 #
	 # If a step has certain dependencies beyond the basic Hydra options
	 # they should be expressed locally (ie at the top of that step).
	 def execute context
	    context
	 end
      end
   end
end
