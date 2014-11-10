require_relative 'spec_helper'

describe 'static analysis checks' do
  it 'shellcheck' do
    begin
      run('which shellcheck', out: false, out_ex: true)
    rescue
      pending 'Unable to run shellcheck.  See http://www.shellcheck.net/about.html ' \
                'or on OSX, install via `brew insetall shellcheck`'
      raise
    end

    begin
      run("shellcheck #{gitrflow_script}", out: false, out_ex: true)
    rescue
      $stderr.puts('Shellcheck failed.  See https://github.com/koalaman/shellcheck/wiki')
      raise
    end
  end

  it 'ruby-lint' do
    run("ruby-lint #{File.expand_path('../../spec', __FILE__)}", out: false, out_ex: true)
  end

  it 'rubocop' do
    run('rubocop', out: false, out_ex: true)
  end
end
