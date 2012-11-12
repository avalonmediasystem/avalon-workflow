require 'hydrant/workflow/steps/basic_step'

module Hydrant::Workflow::Steps
	class AccessControlStep < BasicStep
		def execute context
		  mediaobject = context[:mediaobject]
	          # TO DO: Implement me
        	  logger.debug "<< Access flag = #{context[:access]} >>"
              	  mediaobject.access = context[:access]        
        
	          mediaobject.save
        	  logger.debug "<< Groups : #{mediaobject.read_groups} >>"
		  context
		end
	end
end
