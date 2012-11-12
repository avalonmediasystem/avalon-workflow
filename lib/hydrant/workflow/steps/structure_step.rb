require 'hydrant/workflow/steps/basic_step'

module Hydrant::Workflow::Steps
	class StructureStep < BasicStep
		def execute context
		  mediaobject = context[:mediaobject]

        if !context[:masterfiles].nil?
          masterFiles = []
          context[:masterfiles].each do |mf_id|
            mf = MasterFile.find(mf_id)
            masterFiles << mf
          end

          # Clean out the parts
          masterFiles.each do |mf|
            mediaobject.parts_remove mf
          end
          mediaobject.save(validate: false)
          
          # Puts parts back in order
          masterFiles.each do |mf|
            mf.container = mediaobject
            mf.save
          end
          mediaobject.save(validate: false)
        end
		  context
		end
	end
end
