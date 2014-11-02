require_relative 'spec_helper'

describe 'static analysis checks' do
  it 'shellcheck' do
    begin
      process('which shellcheck', puts_output: false)
    rescue
      pending 'Unable to run shellcheck.  See http://www.shellcheck.net/about.html ' \
                'or on OSX, install via `brew insetall shellcheck`'
      raise
    end

    begin
      process("shellcheck #{gitrflow_path}")
    rescue
      $stderr.puts('Shellcheck failed.  See https://github.com/koalaman/shellcheck/wiki')
      raise
    end
  end

  it 'ruby-lint' do
    process("ruby-lint #{File.expand_path('../../spec', __FILE__)}")
  end

  it 'rubocop' do
    process('rubocop')
  end
end
