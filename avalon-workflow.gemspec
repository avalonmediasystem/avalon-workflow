require File.expand_path('../lib/avalon-workflow/version', __FILE__)

Gem::Specification.new do |gem|
	gem.license = "Apache 2.0"
	gem.authors = ["rogersna"]
	gem.email = ["rogersna@indiana.edu"]
	gem.description = %q{Workflow processing for Avalon based applications}
	gem.summary = %q{This is an abstraction of the workflow for ingesting and processing multimedia content that allows for arbitrary steps ti easily be added to a pipeline}
	
	gem.files = Dir["lib/**/*"] + Dir["vendor/**/*"] + Dir["app/**/*"] + 
			["README.md"]
	gem.executables = []
	gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
	gem.name = 'avalon-workflow'
	gem.require_paths = ["lib", "app"]
	gem.version = Avalon::Workflow::VERSION
end
