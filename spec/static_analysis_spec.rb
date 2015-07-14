require_relative 'spec_helper'

describe 'static analysis checks' do
  it 'shellcheck' do
    shellcheck_executable = nil
    begin
      # check on path
      run('which shellcheck', out: :error, out_ex: true)
      shellcheck_executable = 'shellcheck'
    rescue
      begin
        # see if linux version works (i.e. if we're on linux)
        linux_exe = File.expand_path('../../spec/shellcheck/linux_x86-64/shellcheck', __FILE__)
        run("#{linux_exe} --version", out: :error, out_ex: true)
        shellcheck_executable = linux_exe
      rescue
        pending 'Unable to run shellcheck.  See http://www.shellcheck.net/about.html ' \
                  'or on OSX, install via `brew insetall shellcheck`, ' \
                  'or on Linux, try the included binary at spec/shellcheck/linux_x86-64'
        raise
      end
    end

    begin
      run("#{shellcheck_executable} #{gitrflow_script_path}", out: :error, out_ex: true)
    rescue
      $stderr.puts('Shellcheck failed.  See https://github.com/koalaman/shellcheck/wiki')
      raise
    end
  end

  it 'ruby-lint' do
    run("ruby-lint #{File.expand_path('../../spec', __FILE__)}", out: :error, out_ex: true)
  end

  it 'rubocop' do
    run('rubocop', out: :error, out_ex: true)
  end
end
