class WorkflowDatastream < ActiveFedora::NokogiriDatastream
  include ActiveRecord::Validations

  before_save :reset_values

  set_terminology do |t|
    t.root(path: 'workflow')
    
    t.last_completed_step(path: 'last_completed_step')
    t.published(path: 'published')
    t.origin(path: 'origin')
  end

  def published?
    published.eql? 'published'
  end

      # Return true if the step is current or prior to the parameter passed in
      # Defaults to false if the step is not recognized
      def completed?(step_name)
        status_flag = published? || false
        unless published?
          step_index = HYDRANT_STEPS.index(step_name)
          current_index = HYDRANT_STEPS.index(step_name)
          last_index = HYDRANT_STEPS.index(last_completed_step.first)
          unless (current_index.nil? or last_index.nil?)
            status_flag = (last_index >= current_index)
          end
        end
        status_flag
      end

      # Current can be true if the last_completed_step is defined as the
      # step prior to the current one. If the step given is the first and
      # the value of last_completed_step is blank then it is also true
      #
      # Otherwise assume the result should be false because you are on a
      # different step
      def current?(step_name)
        current = case
                  when HYDRANT_STEPS.first?(step_name)
                    last_completed_step.first.empty?
                  when HYDRANT_STEPS.exists?(step_name)
                    previous_step = HYDRANT_STEPS.previous(step_name)
                    (last_completed_step == previous_step.step)
                  else
                    false
                  end

        current
      end
      
      def active?(step_name)
        completed?(step_name) or current?(step_name)
      end

      def advance
        last_completed_step = HYDRANT_STEPS.next(last_completed_step.first).step
      end

      def publish
        last_completed_step = "published"
        published = true
      end
      
  def update_status(active_step=nil)
    logger.debug "<< UPDATE_INGEST_STATUS >>"
    logger.debug "<< Updating current ingest step >>"

      active_step = active_step || last_completed_step.first
      logger.debug "<< COMPLETED : #{completed?(active_step)} >>"

      if HYDRANT_STEPS.last? active_step and completed? active_step
        publish
      end
      logger.debug "<< PUBLISHED : #{published?} >>"

      if current?(active_step) and not published?
        logger.debug "<< ADVANCING to the next step in the workflow >>"
        logger.debug "<< #{active_step} >>"
        last_completed_step = advance
      end
  end

  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.workflow do
        xml.last_completed_step '' 
        xml.published 'false'
        xml.origin 'unknown' 
      end
    end
    
    builder.doc
  end

  def to_solr(solr_doc=SolrDocument.new)
    super(solr_doc)

    case last_completed_step.first
    when ''
      solr_doc.merge!(:workflow_status_facet => "New")
    when 'preview'
      solr_doc.merge!(:workflow_status_facet => "Completed")
    default
      solr_doc.merge!(:workflow_status_facet => "In progress")
    end
    solr_doc.merge!(:workflow_published_facet => published.first.capitalize)
    solr_doc.merge!(:workflow_source_facet => origin.first.capitalize)
  end

      protected
      def reset_values
        logger.debug "<< BEFORE_SAVE (IngestStatus) >>"
        logger.debug "<< last_completed_step => #{last_completed_step} >>"
        
        if published.nil?
          logger.debug "<< Default published flag = false >>"
          published = false
        end
        
        if last_completed_step.nil?
          logger.debug "<< Default step = #{HYDRANT_STEPS.first.step} >>"
          last_completed_step = HYDRANT_STEPS.first.step
        end
      end



end
