require_relative 'spec_helper'

describe 'update' do
  before do
    @gitrflow_command = 'update'
  end

  it 'is documented' do
    help_text = 'update'
    expect(run(gitrflow_script('-h'), out: :error, exp_st: 1)).to match(/#{help_text}/)
  end

  describe 'fails if' do
    it 'local repo is not clean' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        FileUtils.touch('dirty')
        cmd = gitrflow_cmd(@gitrflow_command)
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
          cmd = gitrflow_cmd(@gitrflow_command)
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
        cmd = gitrflow_cmd(@gitrflow_command)
        out = run(cmd, out: :error, exp_st: 1)
        expect(out).to match(/ERROR: Local repo has unpushed changes. Please fix and retry./)
      end
    end
  end

  describe 'on master' do
    it 'prints message if no remote commits to pull' do
      local_repo, _ = make_cloned_repo
      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd(@gitrflow_command)
        out = run(cmd, out: :error)
        expected_msg = /Up to date! No changes to pull from remote branch 'origin\/master'\.\n/
        expect(out).to match(expected_msg)
      end
    end

    it 'pulls remote commits' do
      local_repo, remote_repo = make_cloned_repo
      remote_sha = nil
      FileUtils.cd(remote_repo) do
        FileUtils.touch('unpulled')
        run('git add unpulled && git commit -m "unpulled"', out: :error)
        remote_sha = run('git rev-parse HEAD', out: :error)
      end
      FileUtils.cd(local_repo) do
        cmd = gitrflow_cmd(@gitrflow_command)
        out = run(cmd, out: :error)
        expected_msg1 = /Rebasing local branch 'master' onto remote branch 'origin\/master'...\n/
        expected_msg2 = /Rebase complete!  Local branch 'master' is now up-to-date.\n/
        expect(out).to match(expected_msg1)
        expect(out).to match(expected_msg2)
        local_sha = run('git rev-parse HEAD', out: :error)
        expect(local_sha).to eq(remote_sha)
      end
    end
  end
end
