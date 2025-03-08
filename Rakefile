task :default do
  puts 'Welcome to rake tasks!'
end

desc 'Compile all SLIM templates in html'
task :build, [:output_dir] do |_, args|
  output_dir = args[:output_dir] || 'docs'
  require_relative 'lib/slim_compiler'
  SlimCompiler.new(output_dir: output_dir).compile_all
end

desc 'Deploy site to GitHub Pages'
task :deploy do
  require_relative 'lib/deploy_manager'
  DeployManager.new.deploy
end
