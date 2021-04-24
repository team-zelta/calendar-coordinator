# frozen_string_literal: true

require 'rake/testtask'

desc 'Check Vulnerable Dependencies'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Ruby Test'
Rake::TestTask.new(:spec) do |t|
  t.test_files = FileList['spec/*.rb']
end

desc 'Check Style and Performance'
task :style do
  sh 'rubocop'
end
