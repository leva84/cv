# frozen_string_literal: true

require 'logger'

# Deploymanager controls the deploy process on Github Pages
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
      abort("Error: Deployment is allowed only from the 'main' branch. Current branch: '#{ current_branch }'")
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

  # Step 4: Committing changes, if there is something to commit
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

  # Step 5: Push changes in the Main branch
  def push_changes_to_main
    logger.info "Pushing changes to branch '#{ current_branch }'..."
    system("git push origin #{ current_branch }") || abort('Error while pushing changes to main.')
  end

  # Step 6: Deploy site in gh-pages
  def deploy_to_gh_pages
    logger.info "Switching to the 'gh-pages' branch for deployment."
    ensure_branch_exists
    switch_to_gh_pages_branch
    commit_docs_changes
    push_gh_pages_changes
    switch_back_to_main_branch
  end

  def ensure_branch_exists
    return if system('git show-ref --quiet refs/heads/gh-pages')

    logger.info "'gh-pages' branch does not exist. Creating it..."
    abort('Error while creating gh-pages branch.')
  end

  def switch_to_gh_pages_branch
    system('git checkout gh-pages') || abort('Error while switching to gh-pages branch.')
  end

  def commit_docs_changes
    logger.info "Checking for changes in the 'docs' directory..."

    status = `git status --porcelain #{ output_dir }`.strip

    if status.empty?
      logger.info "No changes detected in the '#{ output_dir }' directory. Skipping commit."
    else
      logger.info "Changes detected in '#{ output_dir }'. Staging and committing..."
      system("git add #{ output_dir }") || abort("Error while staging changes in '#{ output_dir }'.")
      system('git commit -m "Update docs in gh-pages"') || logger.info('No changes to commit, skipping...')
    end
  end

  def push_gh_pages_changes
    logger.info 'Pushing changes to origin/gh-pages.'
    system('git push -u origin gh-pages') || abort('Error while pushing changes to gh-pages branch.')
    logger.info 'Deployment to gh-pages completed successfully!'
  end

  def switch_back_to_main_branch
    logger.info "Switching back to '#{ current_branch }' branch."
    system("git checkout #{ current_branch }") || abort('Error while switching back to main branch.')
  end
end
