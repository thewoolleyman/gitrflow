require_relative 'spec_helper'

describe 'feature start' do
  it 'is documented' do
    help_text = 'feature start <branch_name>'
    expect(run(gitrflow_script('-h'), out: false, exp_rc: 1)).to match(/#{help_text}/)
  end

  describe 'fails if' do
    it 'no branch name is specified' do
      out = run(gitrflow_cmd('feature start'), out: false, exp_rc: 1)
      expect(out).to match(/ERROR: The feature branch name is required./)
      expect(out).to match(/'git-rflow --help' for usage./)
    end

    it 'local repo is not clean' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        FileUtils.touch('dirty')
        cmd = gitrflow_cmd('feature start feature1')
        out = run(cmd, out: false, exp_rc: 1)
        expect(out).to match(/ERROR: Local repo is not clean. Please fix and retry./)
      end
    end

    it 'local repo is "gone"' do
      if git_version_has_gone_repos
        local_repo, _ = make_cloned_repo([])
        FileUtils.cd(local_repo) do
          FileUtils.touch('unpushed')
          run('git add unpushed && git commit -m "unpushed"', out: false)
          cmd = gitrflow_cmd('feature start feature1')
          out = run(cmd, out: false, exp_rc: 1)
          expect(out).to match(/ERROR: Local repo is "gone". Please fix and retry./)
        end
      end
    end

    it 'local repo has unpushed changes' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        FileUtils.touch('unpushed')
        run('git add unpushed && git commit -m "unpushed"', out: false)
        cmd = gitrflow_cmd('feature start feature1')
        out = run(cmd, out: false, exp_rc: 1)
        expect(out).to match(/ERROR: Local repo has unpushed changes. Please fix and retry./)
      end
    end
  end

  it 'creates the specified feature branch' do
    local_repo, _ = make_cloned_repo
    branch = 'feature1'
    expected_out = "Summary of actions:\n" \
      "- A new branch '#{branch}' was created, based on 'master'\n" \
      "- You are now on branch '#{branch}'\n\n" \
      "Now, start committing on your feature. When done, use:\n\n" \
      "     git flow feature finish #{branch}\n"

    FileUtils.cd(local_repo) do
      cmd = gitrflow_cmd("feature start #{branch}")
      out = run(cmd, out: false)
      expect(out).to eq(expected_out)
      git_status = run('git status', out: false)
      expect(git_status).to match(/On branch #{branch}/)
    end
  end
end
