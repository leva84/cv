# frozen_string_literal: true

require 'logger'

# Deploymanager controls the Deflow process on Github Pages
class DeployManager
  attr_reader :logger, :current_branch, :output_dir

  def initialize(output_dir: 'docs', logger: Logger.new($stdout))
    @logger = logger
    @output_dir = output_dir
    @current_branch = `git branch --show-current`.strip
  end

  def deploy
    check_main_branch
    logger.info 'Starting deployment process...'

    build_site
    add_changes_to_git
    commit_changes
    push_changes_to_main
    deploy_to_gh_pages

    logger.info 'Deployment completed successfully 🎉'
  end

  private

  # Step 1: Checking the current branch
  def check_main_branch
    if current_branch != 'main'
      abort("Error: Deployment is allowed only from the 'main' branch. Current branch: '#{current_branch}'")
    end
    logger.info "You are on the 'main' branch. Proceeding with deployment..."
  end

  # Step 2: The compiler starts the assembly
  def build_site
    logger.info 'Building the site...'
    Rake::Task['build'].invoke
  end

  # Step 3: Adding all changes to Git
  def add_changes_to_git
    logger.info 'Adding changes to Git...'
    system('git add .') || abort('Error while adding files to Git.')
  end

  # Step 4: Committing changes, if there is something to commander
  def commit_changes
    logger.info 'Checking for changes to commit...'
    status = `git status --porcelain`.strip

    if status.empty?
      logger.info 'No changes to commit. Skipping commit step...'
    else
      logger.info 'Creating a new commit...'
      system('git commit -m "Deploy updated site"') || abort('Error committing changes.')
    end
  end

  # Step 5: Changes in the Main branch
  def push_changes_to_main
    logger.info "Pushing changes to branch '#{ current_branch } '..."
    system("git push origin #{ current_branch }") || abort('Error while pushing changes to main.')
  end

  # Step 6: Deet site in gh-pages
  def deploy_to_gh_pages
    logger.info "Switching to the 'gh-pages' branch for deployment."

    # Проверяем наличие ветки gh-pages, если ее нет — создаем
    unless system('git show-ref --quiet refs/heads/gh-pages')
      logger.info "'gh-pages' branch does not exist. Creating it..."
      system('git checkout --orphan gh-pages') ||
        abort('Error while creating gh-pages branch.')
      system('git rm -rf .') || abort('Error while clearing initial contents.')
      system('git commit --allow-empty -m "Initialize gh-pages branch"') ||
        abort('Error while initializing gh-pages branch.')
      system('git push origin gh-pages') || abort('Error while pushing gh-pages branch.')
    end

    # Переключаемся на ветку gh-pages
    system('git checkout gh-pages') || abort('Error while switching to gh-pages branch.')

    logger.info "Copying new files to 'gh-pages/docs'..."
    # Копируем только содержимое папки docs из ветки main
    system('git checkout main -- docs') || abort('Error while copying docs folder.')

    logger.info "Staging only changes from the 'docs' directory..."
    # Добавляем в индекс только папку docs, избегая глобального git add
    system('git add docs') || abort('Error while staging docs folder.')

    logger.info "Committing changes to 'gh-pages'."
    system('git commit -m "Update docs in gh-pages"') ||
      logger.info('No changes to commit, skipping...')

    logger.info 'Pushing changes to origin/gh-pages.'
    system('git push origin gh-pages') || abort('Error while pushing changes to gh-pages branch.')

    # Возвращаемся на основную ветку
    logger.info "Switching back to '#{current_branch}' branch."
    system("git checkout #{current_branch}") || abort('Error while switching back to main branch.')

    logger.info 'Deployment to gh-pages completed successfully!'
  end
end
