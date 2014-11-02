require_relative 'spec_helper'

describe 'options' do
  it 'prints error if no options are passed' do
    expect(
      run("#{gitrflow_path}", out: false, exp_rc: 1)
    ).to match(/Usage: /m)
  end

  it 'ignores all options after --' do
    expect(
      run("#{gitrflow_path} -- --version", out: false, exp_rc: 1)
    ).to match(/^    --\t\tIgnore all following options/m)
  end

  it '-h, --help' do
    expect(run("#{gitrflow_path} --help", out: false, exp_rc: 1)).to match(/^Usage:/)
    expect(run("#{gitrflow_path} -h", out: false, exp_rc: 1)).to match(/^Usage:/)
  end

  it '--version' do
    expect(run("#{gitrflow_path} --version", out: false)).to match(/\d\.\d\.\d/)
    expect(run("#{gitrflow_path} -V", out: false)).to match(/\d\.\d\.\d/)
    expect(
      run("#{gitrflow_path}", out: false, exp_rc: 1)
    ).to match(/^    -V, --version/m)
  end
end
