require_relative 'spec_helper'

describe 'feature' do
  describe 'fails if' do
    it 'no command is specified' do
      out = run("#{gitrflow_cmd} feature", out: false, exp_rc: 1)
      expect(out).to match(/ERROR: The feature branch command is required./)
      expect(out).to match(/'git rflow --help' for usage./)
    end
  end
end
