require_relative 'spec_helper'

describe 'lib versions' do
  describe 'verifies' do
    it 'expected version of bash is actually being used' do
      unless bash_executable == 'bash'
        version = bash_executable.split('/')[-2].split('-')[-1]
        expect(run("#{bash_executable} --version", out: :error)).to match(version)
      end
    end

    it 'expected version of git is actually being used' do
      unless git_executable == 'git'
        version = git_executable.split('/')[-2].split('-')[-1]
        cmd = "#{bash_executable} -c '#{git_executable} --version'"
        expect(run(cmd, out: :error)).to match(version)
      end
    end
  end
end
