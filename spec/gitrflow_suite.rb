#!/usr/bin/env ruby
require 'fileutils'
require_relative 'process_helper'

# Runs specs under multiple versions of git
class GitrflowSuite
  include ProcessHelper

  def run_suite
    bash_versions = ENV['GITRFLOW_SPEC_BASH_VERSIONS'] || '3.2.57,4.3.30'
    git_versions = ENV['GITRFLOW_SPEC_GIT_VERSIONS'] || '1.8.2.3,1.9.3'

    bash_src_url_prefix = 'http://ftp.gnu.org/gnu/bash/'
    git_src_url_prefix = 'https://www.kernel.org/pub/software/scm/git/'

    bash_executables = build_all_lib_versions(:bash, bash_versions, bash_src_url_prefix)
    git_executables = build_all_lib_versions(:git, git_versions, git_src_url_prefix)

    # default to latest version
    default_bash_executable = bash_executables.last
    default_git_executable = git_executables.last

    bash_executables.each do |bash_executable|
      run_suite_for_lib_versions(bash_executable, default_git_executable)
    end

    git_executables.each do |git_executable|
      run_suite_for_lib_versions(default_bash_executable, git_executable)
    end
  end

  private

  def build_all_lib_versions(lib_type, lib_versions, lib_src_url_prefix)
    lib_executables = []
    lib_dir = File.expand_path("../#{lib_type}s", __FILE__)
    lib_versions.split(',').each do |lib_version|
      FileUtils.mkdir_p(lib_dir)
      p_div ["Building #{lib_type} version #{lib_version}"]
      lib_executables << build_lib_version(lib_type, lib_version, lib_src_url_prefix, lib_dir)
    end
    lib_executables
  end

  def build_lib_version(lib_type, lib_version, lib_src_url_prefix, lib_dir)
    FileUtils.cd(lib_dir) do
      lib_src_dir = "#{lib_type}-#{lib_version}"
      lib_executable = "#{lib_src_dir}/#{lib_type}"
      lib_src_file = "#{lib_src_dir}.tar.gz"
      lib_src_url = "#{lib_src_url_prefix}#{lib_src_file}"

      run("wget -q #{lib_src_url}", out: false) unless File.exist?(lib_src_file)

      run("tar -zxf #{lib_src_file}", out: false) unless File.exist?(lib_src_dir)

      unless File.exist?(lib_executable)
        FileUtils.cd(lib_src_dir) do
          run('./configure', out: false)
          run('make', out: false)
        end
      end
      return File.expand_path(lib_executable)
    end
  end

  def run_suite_for_lib_versions(bash_executable, git_executable)
    msgs = [
      'Running suite for:',
      "  bash: #{bash_executable.split('/')[-2]}",
      "  git:  #{git_executable.split('/')[-2]}",
    ]
    p_div msgs
    project_root_dir = File.expand_path('../..', __FILE__)
    FileUtils.cd(project_root_dir) do
      run "BASH_EXECUTABLE=#{bash_executable} GIT_EXECUTABLE=#{git_executable} rspec"
    end
  end

  def p_div(msgs)
    puts "\n/#{'-' * 79}\n"
    puts "|\n"
    msgs.each do |msg|
      puts "| #{msg}"
    end
    puts "|\n"
    puts "\\#{'-' * 79}\n\n"
  end
end

GitrflowSuite.new.run_suite
