require_relative 'spec_helper'

describe 'branch type parameter' do
  it 'fails if no command is specified' do
    out = run("PATH=#{path_with_gitrflow} git rflow feature", out: false, exp_rc: 1)
    expect(out).to match(/ERROR: The feature branch command is required./)
    expect(out).to match(/'git rflow --help' for usage./)
  end
end

describe 'start' do
  it 'fails if no branch name is specified' do
    out = run("PATH=#{path_with_gitrflow} git rflow feature start", out: false, exp_rc: 1)
    expect(out).to match(/ERROR: The feature branch name is required./)
    expect(out).to match(/'git rflow --help' for usage./)
  end

  it 'creates the specified feature branch' do
    branch = 'feature/feature1'
    out = run("#{gitrflow_cmd} feature start #{branch}", out: false)
    expect(out).to eq("start feature branch #{branch}\n")
  end
end
