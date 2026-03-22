# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RuboCop::RakeTask.new(:rubocop)

YARD::Rake::YardocTask.new do |task|
  task.options = %w[--fail-on-warning --no-output]
end

desc "Run code quality checks"
task lint: %i[rubocop yard]

task default: %i[lint test]
