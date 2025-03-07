task :default do
  puts 'Welcome to rake tasks!'
end

desc 'Compile all SLIM templates in html'
task :build do
  require 'slim'
  require 'fileutils'

  VIEW_DIR = 'views'
  OUTPUT_DIR = 'docs'

  puts 'Compilation of templates ...'

  FileUtils.mkdir_p(OUTPUT_DIR)

  Dir.glob("#{VIEW_DIR}/*.slim").each do |slim_file|
    html_file = File.join(OUTPUT_DIR, "#{File.basename(slim_file, '.slim')}.html")

    File.write(html_file, Slim::Template.new(slim_file).render)
    puts "Compiled: #{slim_file} -> #{html_file}"
  end

  puts 'The generation is completed.'
end
