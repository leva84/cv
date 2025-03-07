# frozen_string_literal: true

require 'slim'
require 'fileutils'
require 'logger'

# SlimCompiler отвечает за компиляцию Slim шаблонов в HTML.
# Он принимает директории входа (с шаблонами) и выхода (для HTML),
# и по заданию выполняет процесс рендера шаблонов.
class SlimCompiler
  attr_reader :view_dir, :output_dir, :logger

  def initialize(view_dir: 'views', output_dir: 'docs', logger: Logger.new($stdout))
    @view_dir = view_dir
    @output_dir = output_dir
    @logger = logger
  end

  def compile_all
    logger.info "Compilation of templates from '#{view_dir}' to '#{output_dir}'..."

    FileUtils.mkdir_p(output_dir)

    Dir.glob("#{view_dir}/*.slim").each do |slim_file|
      compile_slim(slim_file)
    end

    logger.info 'The generation is completed.'
  end

  private

  def compile_slim(slim_file)
    html_file = File.join(output_dir, "#{File.basename(slim_file, '.slim')}.html")

    File.write(html_file, Slim::Template.new(slim_file).render)
    logger.info "Compiled: #{slim_file} -> #{html_file}"
  end
end
