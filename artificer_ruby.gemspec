require_relative 'lib/artificer_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "artificer_ruby"
  spec.version       = ArtificerRuby::VERSION
  spec.authors       = ["Dan Heneise"]
  spec.email         = ["dan@danarchy.me"]

  spec.summary       = %q{Apple SRE Technical Screening}
  spec.description   = %q{A Ruby gem to routinely pull an upstream repo and archive the existing version.}
  spec.homepage      = "https://github.com/danarchy85/apple_sre"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "artifactory", "~> 3.0"
  spec.add_runtime_dependency "rufus-scheduler", "~> 3.6"
end
