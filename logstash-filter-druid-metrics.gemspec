Gem::Specification.new do |s|
  s.name = 'logstash-filter-druid-metrics'
  s.version = '0.0.1'
  s.licenses = ['AGPL-3.0']
  s.summary = "This plugin allows Logstash to enrich druid metric data"
  s.description = "This plugin allows Logstash to enrich druid metric data"
  s.authors = ["ptorres"]
  s.homepage = "https://github.com/redBorder/logstash-filter-druid-metrics"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir.glob("lib/**/*")

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a Logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_development_dependency 'logstash-devutils'
end
