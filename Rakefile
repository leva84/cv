task :default do
  puts 'Welcome to rake tasks!'
end

desc 'Compile all SLIM templates in html'
task :build do
  require_relative 'lib/slim_compiler'
  # Создаём объект нашего компилятора
  compiler = SlimCompiler.new(view_dir: 'views', output_dir: 'docs')

  # Компилируем все шаблоны
  compiler.compile_all
end
