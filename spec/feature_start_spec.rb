require_relative 'spec_helper'

describe 'feature start' do
  it 'is documented' do
    help_text = 'feature start <branch_name>'
    expect(run(gitrflow_script('-h'), out: :error, exp_st: 1)).to match(/#{help_text}/)
  end

  describe 'fails if' do
    it 'no branch name is specified' do
      out = run(gitrflow_cmd('feature start'), out: :error, exp_st: 1)
      expect(out).to match(/ERROR: The feature branch name is required./)
      expect(out).to match(/'git-rflow --help' for usage./)
    end

    it 'local repo is not clean' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        FileUtils.touch('dirty')
        cmd = gitrflow_cmd('feature start feature1')
        out = run(cmd, out: :error, exp_st: 1)
        expect(out).to match(/ERROR: Local repo is not clean. Please fix and retry./)
      end
    end

    it 'local repo is "gone"' do
      if git_version_has_gone_repos
        local_repo, _ = make_cloned_repo(commits: [])
        FileUtils.cd(local_repo) do
          FileUtils.touch('unpushed')
          run('git add unpushed && git commit -m "unpushed"', out: :error)
          cmd = gitrflow_cmd('feature start feature1')
          out = run(cmd, out: :error, exp_st: 1)
          expect(out).to match(/ERROR: Local repo is "gone". Please fix and retry./)
        end
      end
    end

    it 'local branch has unpushed changes' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        FileUtils.touch('unpushed')
        run('git add unpushed && git commit -m "unpushed"', out: :error)
        cmd = gitrflow_cmd('feature start feature1')
        out = run(cmd, out: :error, exp_st: 1)
        expect(out).to match(/ERROR: Local repo has unpushed changes. Please fix and retry./)
      end
    end

    it 'local branch is behind remote' do
      local_repo, remote_repo = make_cloned_repo

      FileUtils.cd(remote_repo) do
        FileUtils.touch('unpulled')
        run('git add unpulled && git commit -m "unpulled"', out: :error)
      end

      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd('feature start feature1')
        out = run(cmd, out: :error, exp_st: 1)
        msg = 'ERROR: Local repo is behind remote. ' \
          "Please run 'git rflow update' to pull remote updates, then retry."
        expect(out).to match(/#{msg}/)
      end
    end

    it 'current branch is not master' do
      local_repo, _ = make_cloned_repo

      expected_msg = 'ERROR: Local branch is not master.  Currently, git-rflow only supports ' \
        'feature branches created directly off of master.'
      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd('feature start feature1')
        run(cmd, out: :error)

        cmd2 = gitrflow_cmd('feature start feature2')
        out = run(cmd2, out: :error, exp_st: 1)
        expect(out).to match(/#{Regexp.escape(expected_msg)}/)

        git_status = run('git status', out: :error)
        expect(git_status).to match(/On branch feat\/feature1/)
      end
    end
  end

  describe 'creates the specified feature branch and pushes to remote' do
    it 'with default branch prefix' do
      local_repo, _ = make_cloned_repo
      branch = 'feature1'
      prefixed_branch = "feat/#{branch}"
      expected_out = "Summary of actions:\n" \
      "- A new Feature branch 'feat/#{branch}' was created, based on 'master'\n" \
      "- It is pushed to the remote 'origin', " \
        "with a tracking branch of 'origin/feat/#{branch}'\n" \
      "- You are now on branch 'feat/#{branch}'\n\n" \
      "Now, start committing on your feature. When done, use:\n\n" \
      "     git flow feature finish #{branch}\n"

      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd("feature start #{branch}")
        out = run(cmd, out: :error)
        expect(out).to eq(expected_out)
        git_status = run('git status', out: :error)
        expect(git_status).to match(/On branch #{prefixed_branch}/)
        local_sha = run('git log --pretty=format:%H', out: :error)
        remote_sha = run("git log --pretty=format:%H origin/#{prefixed_branch}", out: :error)
        expect(remote_sha).to eq(local_sha)
      end
    end

    it 'with a custom branch prefix' do
      local_repo, _ = make_cloned_repo(init_input_lines: ['f/'])
      branch = 'feature1'
      expected_out = "Summary of actions:\n" \
      "- A new Feature branch 'f/#{branch}' was created, based on 'master'\n" \
      "- It is pushed to the remote 'origin', " \
        "with a tracking branch of 'origin/f/#{branch}'\n" \
      "- You are now on branch 'f/#{branch}'\n\n" \
      "Now, start committing on your feature. When done, use:\n\n" \
      "     git flow feature finish #{branch}\n"

      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd("feature start #{branch}")
        out = run(cmd, out: :error)
        expect(out).to eq(expected_out)
        git_status = run('git status', out: :error)
        expect(git_status).to match(/On branch f\/#{branch}/)
      end
    end
  end
end
