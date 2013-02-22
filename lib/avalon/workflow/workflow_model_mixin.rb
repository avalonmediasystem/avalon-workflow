require 'avalon/workflow/workflow_datastream'

module Avalon::Workflow
  module WorkflowModelMixin
    def self.included(klazz)
      klazz.has_metadata name: 'workflow', type: WorkflowDatastream
    end
  end
end
