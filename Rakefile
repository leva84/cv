task :default do
  puts 'Welcome to rake tasks!'
end

desc 'Compile all SLIM templates in html'
task :build do
  BASE_URL = ENV['BASE_URL'] || ''
  require_relative 'lib/slim_compiler'
  SlimCompiler.new.compile_all
end

desc "Build for development"
task :build_dev do
  BASE_URL = ENV['BASE_URL'] || '../docs/'
  require_relative 'lib/slim_compiler'
  SlimCompiler.new.compile_all
end

desc 'Deploy site to GitHub Pages'
task :deploy do
  require_relative 'lib/deploy_manager'
  DeployManager.new.deploy
end
