class WorkflowDatastream < ActiveFedora::NokogiriDatastream
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

  def published= publication_status
     publishedVal = publication_status ? 'published' : 'unpublished'
     update_values({[{:published=>"0"}]=>{"0"=>publishedVal}})
  end

  def last_completed_step= active_step
    active_step = active_step.first if active_step.is_a? Array
    unless HYDRANT_STEPS.exists? active_step
      logger.warn "Unrecognized step : #{active_step}"
    end
    
    # Set it anyways for now. Need to come up with a more robust warning
    # system down the road
    update_values({[{:last_completed_step=>"0"}]=>{"0"=>active_step}})
  end 
  
  def origin= source
    unless ['batch', 'web', 'console'].include? source
      logger.warn "Unrecognized origin : #{source}"
      update_values({[{:origin=>"0"}]=>{"0"=>"unknown"}})
    else
      update_values({[{:origin=>"0"}]=>{"0"=>source}})
    end
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
			  logger.debug "<< Option 1 >>"
                    last_completed_step.first.empty?
                  when HYDRANT_STEPS.exists?(step_name)
			  logger.debug "<< Option 2 >>"
                    previous_step = HYDRANT_STEPS.previous(step_name)
                    (last_completed_step.first == previous_step.step)
                  else
			  logger.debug "<< Option 3 >>"
                    false
                  end

        current
      end
      
      def active?(step_name)
        completed?(step_name) or current?(step_name)
      end

      # Advance should recognize that a step is invalid and respond by 
      # defaulting to the first known step. If you are already on the last
      # step then don't advance any further. There's a potential for silently
      # failing here but this is a first pass only
      def advance
	lcs = (last_completed_step.is_a? Array) ? last_completed_step.first : last_completed_step

	if (lcs.blank? or not HYDRANT_STEPS.exists?(lcs))
	  self.last_completed_step = HYDRANT_STEPS.first.step
	elsif (not HYDRANT_STEPS.last?(lcs))
	  next_step = HYDRANT_STEPS.next(lcs).step
	  logger.debug "<< Advancing to the next step - #{next_step} >>"
          self.last_completed_step = next_step 
        end
      end

      def publish
        self.last_completed_step = HYDRANT_STEPS.last.step 
        self.published = true.to_s
      end
      
  def update_status(active_step=nil)
    logger.debug "<< UPDATE_INGEST_STATUS >>"

      active_step = active_step || last_completed_step.first
      logger.debug "<< COMPLETED : #{completed?(active_step)} >>"

      if HYDRANT_STEPS.last? active_step and completed? active_step
        publish
      end
      logger.debug "<< PUBLISHED : #{published?} >>"

      if current?(active_step) and not published?
        logger.debug "<< ADVANCING to the next step in the workflow >>"
        logger.debug "<< #{active_step} >>"
        advance
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

    solr_value = case last_completed_step.first
    when blank?
      'New'
    when 'preview'
      'Completed'
    else
      'In progress'
    end
    solr_doc.merge!(workflow_status_facet: solr_value)

    published_value = published? ? 'Published' : 'Unpublished'
    solr_doc.merge!(:workflow_published_facet => published_value)
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
