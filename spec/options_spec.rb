require_relative 'spec_helper'

describe 'options' do
  it 'prints error if no options are passed' do
    expect(
      run("#{gitrflow_cmd}", out: false, exp_rc: 1)
    ).to match(/Usage: /m)
  end

  it 'ignores all options after --' do
    expect(
      run("#{gitrflow_cmd} -- --version", out: false, exp_rc: 1)
    ).to match(/^    --\t\tIgnore all following options/m)
  end

  it 'processes options after commands' do
    out = run("#{gitrflow_cmd} feature start feature1 --version", out: false)
    expect(out).to match(version_regex)
  end

  it '-h, --help' do
    expect(run("#{gitrflow_path} --help", out: false, exp_rc: 1)).to match(/^Usage:/)
    expect(run("#{gitrflow_path} -h", out: false, exp_rc: 1)).to match(/^Usage:/)
  end

  it '--version' do
    expect(run("#{gitrflow_cmd} --version", out: false)).to match(version_regex)
    expect(run("#{gitrflow_cmd} -V", out: false)).to match(version_regex)
    expect(
      run("#{gitrflow_cmd}", out: false, exp_rc: 1)
    ).to match(/^    -V, --version/m)
  end

  def version_regex
    /^git-rflow, version \d\.\d\.\d/
  end
end
