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

RuboCop::RakeTask.new
YARD::Rake::YardocTask.new do |task|
  task.options = %w[--fail-on-warning --no-output]
end

desc "Run code quality checks"
task lint: :rubocop

task default: %i[lint test]
