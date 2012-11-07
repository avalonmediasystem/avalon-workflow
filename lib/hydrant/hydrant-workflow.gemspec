require File.expand_path('lib/hydrant-workflow/version', __FILE__)

Gem::Specifications.new do |gem|
	gem.authors = ["rogersna"]
	gem.email = ["rogersna@indiana.edu"]
	gem.description = %q{Workflow processing for Hydrant based applications}
	gem.summary = %q{This is an abstraction of the workflow for ingesting and processing multimedia content that allows for arbitrary steps ti easily be added to a pipeline}
	
	gem.files = Dir["lib/**/*"] + Dir["vendor/**/*"] + Dir["app/**/*"] + 
			["readme.md"]
	gem.executables = []
	gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
	gem.name = 'hydrant-workflow'
	gem.require_paths = ["lib"]
	gem.version = Hydrant::Workflow::VERSION
end
