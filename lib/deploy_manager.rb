# frozen_string_literal: true

require 'logger'

# DeployManager handles the deployment process to GitHub Pages
class DeployManager
  MAIN_BRANCH = 'main'
  GH_PAGES_BRANCH = 'gh-pages'
  DOCS_DIR = 'docs'
  TEMP_DIR = 'tmp/deploy_docs'

  attr_reader :logger, :output_dir

  def initialize(logger: Logger.new($stdout))
    @logger = logger
  end

  def deploy
    ensure_on_branch(MAIN_BRANCH)
    logger.info 'Starting deployment process...'

    build_site
    copy_site_to_temp
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

  # Copy static site
  def copy_site_to_temp
    logger.info 'Copying site...'
    FileUtils.cp_r("#{ DOCS_DIR }/.", TEMP_DIR)
  end

  # Deploys site to gh-pages branch
  def deploy_to_gh_pages
    ensure_on_branch(GH_PAGES_BRANCH)

    # Restore files from TEMP_DIR to DOCS_DIR
    logger.info "Copying files from temporary directory '#{ TEMP_DIR }' to '#{ DOCS_DIR }'..."
    FileUtils.rm_rf(DOCS_DIR) # Clear docs/ content
    FileUtils.mkdir_p(DOCS_DIR) # Recreate docs/ directory
    FileUtils.cp_r("#{ TEMP_DIR }/.", DOCS_DIR)

    # Stage and commit changes in the gh-pages branch
    logger.info "Committing changes to #{ GH_PAGES_BRANCH }..."
    stage_changes(DOCS_DIR)
    commit_changes("Deploy updated site - #{ Time.now.strftime('%Y-%m-%d %H:%M:%S') }", skip_empty: true)
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
