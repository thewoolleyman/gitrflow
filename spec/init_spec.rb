require_relative 'spec_helper'

describe 'init' do
  it 'is documented' do
    help_text = /gitrflow \[global options\] init \[--defaults\]\n/
    expect(run(gitrflow_script('-h'), out: false, exp_rc: 1)).to match(help_text)
  end

  describe 'fails if' do
    it 'a command is run on an uninitialized repo' do
      local_repo, _ = make_cloned_un_gitrflow_initialized_repo
      FileUtils.cd(local_repo) do
        out = run(gitrflow_cmd('feature start feature1'), out: false, exp_rc: 1)
        expected_msg = 'ERROR: Not a gitrflow-enabled repo yet. ' \
          'Please run "git rflow init [--defaults]" first.'
        expect(out).to match(/#{Regexp.escape(expected_msg)}/)
      end
    end
  end

  describe '--defaults option' do
    it 'assigns all defaults without prompting' do
      init_defaults_cmd = gitrflow_cmd('init --defaults')
      out = run(init_defaults_cmd, out: false)
      expected_out = "Using default branch prefixes:\n" \
        "  Feature branches: 'feat/'\n"
      expect(out).to eq(expected_out)
      feature_prefix_config_get_cmd = 'git config --get gitrflow.prefix.feature'
      config_output = run(feature_prefix_config_get_cmd, out: false, exp_rc: 0)
      expect(config_output).to eq("feat/\n")
    end
  end

  describe 'prompts' do
    before do
      @init_cmd = gitrflow_cmd('init')
    end

    describe 'prefix' do
      describe 'for feature branches' do
        before do
          @config_get_cmd = 'git config --get gitrflow.prefix.feature'
        end

        it 'and defaults on blank entry' do
          input_lines = ['']
          out = run(@init_cmd, in: input_lines, out: false)
          expected_out = "What prefix will you use for feature branches? [feat/]\n"
          expect(out).to eq(expected_out)
          config_output = run(@config_get_cmd, out: false, exp_rc: 0)
          expect(config_output).to eq("feat/\n")
        end

        it 'and allows override' do
          overridden_feature_branch_prefix = 'f/'
          input_lines = [overridden_feature_branch_prefix]
          out = run(@init_cmd, in: input_lines, out: false)
          expected_out = "What prefix will you use for feature branches? [feat/]\n"
          expect(out).to eq(expected_out)
          config_output = run(@config_get_cmd, out: false, exp_rc: 0)
          expect(config_output).to eq("#{overridden_feature_branch_prefix}\n")
        end
      end
    end
  end
end
