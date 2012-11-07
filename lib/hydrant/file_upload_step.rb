require 'hydrant/dropbox'

module Hydrant
	module Workflow
		# For file uploads the process of setting the context is easy. We
		# just need to ask the dropbox if there are any files. If so load
		# them into a variable that can be referred to later
		def self.before_step context
	       dropbox_files = Hydrant::DropboxService.all
		   context[:dropbox_files] = @dropbox_files 
		   context
		end

		def self.after_step
		end

		def self.execute context
	       logger.debug "<< Processing FILE-UPLOAD step >>"
		   update_master_files context[:mediaobject], context[:parts] 
		   unless context[:mediaobject].parts.empty?
		       media = context[:mediaobject]
			   media.format = media.parts.first.media_type
			   media.save(validate: false)
			   context[:mediaobject] = media
		   end

		   context
		end
	end
end
