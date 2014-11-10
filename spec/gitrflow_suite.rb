#!/usr/bin/env ruby
require 'fileutils'
require_relative 'process_helper'

# Runs specs under multiple versions of git
class GitrflowSuite
  include ProcessHelper

  def run_suite
    git_versions = ENV['GITRFLOW_SPEC_GIT_VERSIONS'] || '1.8.2.3,1.9.3'

    @gits_dir = File.expand_path('../gits', __FILE__)
    git_versions.split(',').each do |git_version|
      FileUtils.mkdir_p(@gits_dir)
      p_div "Running specs with git_version #{git_version}"
      git_executable = build_git_version(git_version)
      run_suite_for_git_version(git_executable)
    end
  end

  private

  def build_git_version(git_version)
    FileUtils.cd(@gits_dir) do
      git_src_dir = "git-#{git_version}"
      git_executable = "#{git_src_dir}/git"
      git_src_file = "#{git_src_dir}.tar.gz"
      git_src_url = "https://www.kernel.org/pub/software/scm/git/#{git_src_file}"

      run("wget -q #{git_src_url}") unless File.exist?(git_src_file)

      run("tar -zxf #{git_src_file}") unless File.exist?(git_src_dir)

      unless File.exist?(git_executable)
        FileUtils.cd(git_src_dir) do
          run('./configure')
          run('make')
        end
      end
      return File.expand_path(git_executable)
    end
  end

  def run_suite_for_git_version(git_executable)
    project_root_dir = File.expand_path('../..', __FILE__)
    FileUtils.cd(project_root_dir) do
      run "GIT_EXECUTABLE=#{git_executable} rspec"
    end
  end

  def p_div(msg)
    puts "\n/#{'-' * 79}\n"
    puts "|\n"
    puts "| #{msg}"
    puts "|\n"
    puts "\\#{'-' * 79}\n\n"
  end
end

GitrflowSuite.new.run_suite
