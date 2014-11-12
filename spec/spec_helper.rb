require 'rspec'
require 'tmpdir'
require_relative 'process_helper'

# RSpec config
RSpec.configure do |c|
  c.before(:suite) do
    ENV['GIT_AUTHOR_NAME'] = 'gitrflow'
    ENV['GIT_AUTHOR_EMAIL'] = 'gitrflow@example.com'
    ENV['GIT_COMMITTER_NAME'] = 'gitrflow'
    ENV['GIT_COMMITTER_EMAIL'] = 'gitrflow@example.com'
  end
end

# RSpec helper methods
module SpecHelper
  include ProcessHelper

  # Uncomment to trace complete bash script execution from very beginning,
  # but ordinarily passing --debug option to git-rflow is sufficient.
  # Or, set from command line and debug focused spec with `rspec --example '...'`
  # ENV['GITRFLOW_BASH_XTRACE'] = 'true'

  ###
  ### helpers for bash executable and versions
  ###

  def bash_executable
    ENV['BASH_EXECUTABLE'] || 'bash'
  end

  ###
  ### helpers for git executable and versions
  ###

  def git_executable
    ENV['GIT_EXECUTABLE'] || 'git'
  end

  def git_version
    version_output = run("#{git_executable} --version", out: false)
    regex = /^git version (\d)\.(\d)\.(\d).*/
    match = regex.match(version_output)
    {
      major: match[1].to_i,
      minor: match[2].to_i,
      patch: match[3].to_i,
    }
  end

  def git_version_has_gone_repos
    # TODO: Not sure what version this started in, guessing >= 1.9
    v = git_version
    v[:major] >= 1 && v[:minor] >= 9
  end

  def git_version_status_porcelain_branch_output(
    prefix = '##',
    local = 'master',
    tracking = 'origin/master'
  )
    # TODO: Not sure what version this changed in, guessing <= 1.8.2
    v = git_version
    if v[:major] <= 1 && v[:minor] <= 8 && v[:patch] <= 2
      "#{prefix} #{local}"
    else
      "#{prefix} #{local}...#{tracking}"
    end
  end

  ###
  ### helpers for local invocation of gitrflow
  ###

  def path_with_gitrflow
    "#{File.expand_path('../../', __FILE__)}:$PATH"
  end

  def gitrflow_script_path
    File.expand_path('../../git-rflow', __FILE__)
  end

  def gitrflow_script(args = '')
    "#{bash_executable} -c '#{gitrflow_script_path} #{args}'"
  end

  def gitrflow_cmd(args = '')
    "#{bash_executable} -c 'PATH=#{path_with_gitrflow} #{git_executable} rflow #{args}'"
  end

  ###
  ### support for creating local git repos for testing
  ###

  def init_defaults_output(output_options)
    opts = {}
    output_options.split(' ').each { |o| opts[o] = true }
    out = ''
    out << "git config --get gitrflow.prefix.feature\n" if opts['-c']
    out << "trace: built-in: git 'config' '--get' 'gitrflow.prefix.feature'\n" if opts['-t']
    out << "feat/\n" if opts['-o']
    out
  end

  def make_cloned_repo(commits = nil)
    local_repo_dir, remote_repo_dir = make_cloned_un_gitrflow_initialized_repo(commits)
    FileUtils.cd(local_repo_dir) do
      run(gitrflow_cmd('init --defaults'), out: false)
    end
    [local_repo_dir, remote_repo_dir]
  end

  def make_cloned_un_gitrflow_initialized_repo(commits = nil)
    local_repo_parent_dir = Dir.mktmpdir
    remote_repo_dir = make_remote_repo(commits)
    FileUtils.cd(local_repo_parent_dir) do
      run("git clone #{remote_repo_dir} local_repo", out: false)
    end
    ["#{local_repo_parent_dir}/local_repo", remote_repo_dir]
  end

  def make_remote_repo(commits = nil)
    unless commits == []
      commits = [
        {
          a: 1,
        }
      ]
    end
    remote_repo_dir = Dir.mktmpdir('remote_repo_')
    FileUtils.cd(remote_repo_dir) do
      run('git init', out: false)
      commits.each do |commit|
        commit.each do |filename, contents|
          run("echo #{contents} > #{filename}", out: false)
        end
      end
      run('git add . && git commit -m "commit 1"', out: false) unless commits.empty?
    end
    remote_repo_dir
  end
end
include SpecHelper
