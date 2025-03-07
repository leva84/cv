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

  # Step 2: Building the site
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

  # Step 5: Pushing changes to main
  def push_changes_to_main
    logger.info "Pushing changes to branch '#{ current_branch }'..."
    system("git push origin #{ current_branch }") || abort('Error while pushing changes to main.')
  end

  # Step 6: Deploy site in gh-pages
  def deploy_to_gh_pages
    logger.info "Ensuring 'gh-pages' branch exists..."
    ensure_branch_exists

    logger.info "Merging 'docs' directory from 'main' into 'gh-pages'..."
    merge_docs_from_main_into_gh_pages

    logger.info "Deployment to 'gh-pages' branch starting..."
    push_gh_pages_changes

    logger.info "Switching back to the '#{ current_branch }' branch."
    switching_back_to_main
  end

  def ensure_branch_exists
    return if system('git show-ref --quiet refs/heads/gh-pages')

    logger.info "'gh-pages' branch does not exist. Creating it..."
    system('git checkout -b gh-pages') || abort('Error while creating gh-pages branch.')
    system('git push -u origin gh-pages') || abort('Error while pushing new gh-pages branch to origin.')
  end

  def merge_docs_from_main_into_gh_pages
    system('git checkout gh-pages') || abort('Error while switching to gh-pages branch for merging.')
    system('git fetch origin') || abort('Error while fetching updates from origin.')

    result = system('git checkout origin/main -- docs')
    abort('Error while merging docs from main into gh-pages. Resolve conflicts manually.') unless result
    logger.info "'docs' directory successfully merged from 'main' into 'gh-pages'."

    system('git add docs') || abort("Error while staging 'docs' changes.")
    result = system('git commit -m "Merge docs directory from main into gh-pages"')
    logger.info 'No changes detected in docs during merge. Skipping commit.' unless result
  end

  def push_gh_pages_changes
    logger.info 'Pushing changes to origin/gh-pages.'
    system('git push -u origin gh-pages') || abort('Error while pushing changes to gh-pages branch.')
    logger.info 'Deployment to gh-pages completed successfully!'
  end

  def switching_back_to_main
    system('git checkout main') || abort('Error while switching back to main branch.')
  end
end
