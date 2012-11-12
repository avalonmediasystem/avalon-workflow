module Hydrant::Workflow::Steps
  autoload :BasicStep, 'hydrant/workflow/steps/basic_step'
  autoload :FileUploadStep, 'hydrant/workflow/steps/file_upload_step'
  autoload :ResourceDescriptionStep, 'hydrant/workflow/steps/resource_description_step'
  autoload :StructureStep, 'hydrant/workflow/steps/structure_step'
  autoload :AccessControlStep, 'hydrant/workflow/steps/access_control_step'
  autoload :PreviewStep, 'hydrant/workflow/steps/preview_step'
end
