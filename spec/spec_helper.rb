require 'rspec'
require 'open3'
require 'tmpdir'
require_relative 'process_helper'

# Rspec helper methods
module SpecHelper
  include ProcessHelper

  # Uncomment to trace bash script execution
  # ENV['GITRFLOW_BASH_XTRACE'] = 'true'

  ###
  ### helpers for local invocation of gitrflow
  ###

  def path_with_gitrflow
    "#{File.expand_path('../../', __FILE__)}:$PATH"
  end

  def gitrflow_path
    File.expand_path('../../git-rflow', __FILE__)
  end

  def gitrflow_cmd
    "PATH=#{path_with_gitrflow} git rflow"
  end

  ###
  ### support for creating local git repos for testing
  ###

  def make_cloned_repo(commits = nil)
    local_repo_parent_dir = Dir.mktmpdir
    remote_repo = make_remote_repo(commits)
    FileUtils.cd(local_repo_parent_dir) do
      run("git clone #{remote_repo} local_repo", out: false)
    end
    ["#{local_repo_parent_dir}/local_repo", remote_repo]
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
