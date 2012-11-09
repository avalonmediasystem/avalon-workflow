#require 'file_upload_step'

module Hydrant::Workflow::Steps
		def self.create_step(name, *args)
			name = name.underscore.camelize
			step = nil

			case name
			when 'fileUpload'
				puts 'Foo baz'
				#step = FileUploadStep.new
			end

			step
		end
	end
