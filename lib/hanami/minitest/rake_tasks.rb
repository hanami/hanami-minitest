# frozen_string_literal: true

Hanami::CLI::RakeTasks.register_tasks do
  require "rake/testtask"

  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
  end

  task default: :test
end
