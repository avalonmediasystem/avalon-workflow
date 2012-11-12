require 'hydrant/workflow/steps/basic_step'

module Hydrant::Workflow::Steps
	class ResourceDescriptionStep < BasicStep
		def execute context
		  mediaobject = context[:mediaobject]
	          logger.debug "<< Populating required metadata fields >>"
		  mediaobject.update_datastream(:descMetadata, context[:datastream])
	          logger.debug "<< Updating descriptive metadata >>"
	          mediaobject.save
		  context
		end
	end
end
