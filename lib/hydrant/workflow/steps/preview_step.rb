require 'hydrant/workflow/steps/basic_step'

module Hydrant::Workflow::Steps
	class PreviewStep < BasicStep
		def execute context
		  mediaobject = context[:mediaobject]
	          # Publish the media object
	          mediaobject.avalon_publisher = context[:publisher]
	          mediaobject.save
		  context
		end
	end
end
