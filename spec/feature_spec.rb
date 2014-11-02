require_relative 'spec_helper'

describe 'branch type parameter' do
  it 'fails if no command is specified' do
    out = run("PATH=#{path_with_gitrflow} git rflow feature", out: false, exp_rc: 1)
    expect(out).to match(/ERROR: The feature branch command is required./)
    expect(out).to match(/'git rflow --help' for usage./)
  end
end

describe 'start' do
  describe 'error handling' do
    it 'fails if no branch name is specified' do
      out = run("PATH=#{path_with_gitrflow} git rflow feature start", out: false, exp_rc: 1)
      expect(out).to match(/ERROR: The feature branch name is required./)
      expect(out).to match(/'git rflow --help' for usage./)
    end
  end

  describe 'success' do
    it 'creates the specified feature branch' do
      local_repo, _ = make_cloned_repo
      branch = 'feature1'
      expected_out = "Switched to a new branch '#{branch}'\n\n" \
      "Summary of actions:\n" \
      "- A new branch '#{branch}' was created, based on 'master'\n" \
      "- You are now on branch '#{branch}'\n\n" \
      "Now, start committing on your feature. When done, use:\n\n" \
      "     git flow feature finish #{branch}"

      FileUtils.cd(local_repo) do
        cmd = "#{gitrflow_cmd} feature start #{branch}"
        out = run(cmd, out: false, out_only_on_ex: true)
        expect(out).to eq(expected_out)
        git_status = run('git status', out: false, out_only_on_ex: true)
        expect(git_status).to match(/On branch #{branch}/)
      end
    end
  end
end
