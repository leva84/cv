# frozen_string_literal: true

require 'logger'

# DeployManager handles the deployment process to GitHub Pages
class DeployManager
  MAIN_BRANCH = 'main'
  GH_PAGES_BRANCH = 'gh-pages'
  DOCS_DIR = 'docs'

  attr_reader :logger, :output_dir

  def initialize(output_dir: DOCS_DIR, logger: Logger.new($stdout))
    @logger = logger
    @output_dir = output_dir
  end

  def deploy
    ensure_on_branch(MAIN_BRANCH)
    logger.info 'Starting deployment process...'

    build_site
    stage_changes
    commit_changes("Deploy updated site - #{ Time.now.strftime('%Y-%m-%d %H:%M:%S') }")
    push_changes(MAIN_BRANCH)
    deploy_to_gh_pages

    logger.info 'Deployment successfully completed 🎉'
  end

  private

  ### Main stages ###

  # Builds static site
  def build_site
    logger.info 'Building site...'
    run_command('rake build')
  end

  # Deploys site to gh-pages branch
  def deploy_to_gh_pages
    ensure_branch_exists(GH_PAGES_BRANCH)

    logger.info "Merging '#{ DOCS_DIR }' directory from '#{ MAIN_BRANCH }' to '#{ GH_PAGES_BRANCH} '..."
    merge_docs_from_main

    logger.info "Pushing changes to '#{ GH_PAGES_BRANCH }' branch..."
    push_changes(GH_PAGES_BRANCH)

    ensure_on_branch(MAIN_BRANCH)
  end

  ### Git operations ###

  def ensure_on_branch(branch)
    current_branch = `git branch --show-current`.strip
    if current_branch != branch
      logger.info "Switching to branch '#{ branch }'..."
      run_command("git checkout #{ branch }")
    end
    logger.info "Now on branch '#{ branch }'."
  end

  def ensure_branch_exists(branch)
    return if branch_exists?(branch)

    logger.info "Branch '#{ branch }' does not exist. Creating it..."
    run_command("git checkout -b #{ branch }")
    run_command("git push -u origin #{ branch }")
  end

  def merge_docs_from_main
    ensure_on_branch(GH_PAGES_BRANCH)
    run_command('git fetch origin')

    # Perform targeted checkout of the docs directory from main
    run_command("git checkout origin/#{ MAIN_BRANCH } -- #{output_dir}")
    stage_changes(output_dir)

    # Commit if there are any changes
    commit_changes("Merge #{output_dir} directory from #{ MAIN_BRANCH } to #{ GH_PAGES_BRANCH }", skip_empty: true)
  end

  # Push changes to the remote repository
  def push_changes(branch)
    logger.info "Pushing changes to remote branch '#{ branch }'..."
    run_command("git push origin #{ branch }")
  end

  ### Git helper methods ###

  # Add changes to staging (for a directory or all by default)
  def stage_changes(target = '.')
    logger.info "Staging changes for '#{ target }'..."
    run_command("git add #{ target }")
  end

  # Commit changes with a message
  def commit_changes(message, skip_empty: false)
    if git_status_clean?
      if skip_empty
        logger.info 'No changes to commit. Skipping...'
        return
      end
      abort_with_log("No changes detected. Aborting commit: #{ message }")
    end

    logger.info "Committing changes: #{ message }"
    run_command("git commit -m \"#{ message }\"")
  end

  # Check if working directory is clean
  def git_status_clean?
    `git status --porcelain`.strip.empty?
  end

  # Check if branch exists locally or remotely
  def branch_exists?(branch)
    system("git show-ref --quiet refs/heads/#{ branch }") ||
      system("git show-ref --quiet refs/remotes/origin/#{ branch }")
  end

  ### Command wrapper ###

  def run_command(cmd)
    result = system(cmd)
    abort_with_log("Command failed: #{ cmd }") unless result
    result
  end

  def abort_with_log(message)
    logger.error(message)
    abort(message)
  end
end
