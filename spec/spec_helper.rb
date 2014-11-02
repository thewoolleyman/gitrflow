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

  def make_cloned_repo
    local_repo_parent_dir = Dir.mktmpdir
    remote_repo = make_remote_repo
    cmd = "cd #{local_repo_parent_dir} && git clone #{remote_repo} local_repo"
    run(cmd, out: false, out_only_on_ex: true)
    ["#{local_repo_parent_dir}/local_repo", remote_repo]
  end

  def make_remote_repo
    dir = Dir.mktmpdir('remote_repo_')
    run("cd #{dir} && git init", out: false, out_only_on_ex: true)
    dir
  end
end
include SpecHelper
