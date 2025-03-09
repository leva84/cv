task :default do
  puts 'Welcome to rake tasks!'
end

desc 'Compile all SLIM templates in html'
task :build do
  output_dir = ENV['RECORD_DIR'] || 'docs'
  require_relative 'lib/slim_compiler'
  SlimCompiler.new(output_dir: output_dir).compile_file('index.slim')
end

desc 'Deploy site to GitHub Pages'
task :deploy do
  require_relative 'lib/deploy_manager'
  DeployManager.new.deploy
end
