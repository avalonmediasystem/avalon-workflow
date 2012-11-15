require 'hydrant/workflow/workflow_datastream'

module Hydrant::Workflow
  module WorkflowModelMixin
    def self.included(klazz)
      klazz.has_metadata name: 'workflow', type: WorkflowDatastream
    end
  end
end
