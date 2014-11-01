require_relative 'spec_helper'

describe 'options' do
  it 'prints error if no options are passed' do
    expect(
      process("#{gitrflow_path}", puts_output: false, expected_exit_status: 1)
    ).to match(/Usage: /m)
  end

  it 'ignores all options after --' do
    expect(
      process("#{gitrflow_path} -- --version", puts_output: false, expected_exit_status: 1)
    ).to match(/^    --\t\tIgnore all following options/m)
  end

  it '--version' do
    expect(process("#{gitrflow_path} --version", puts_output: false)).to match(/\d\.\d\.\d/)
    expect(process("#{gitrflow_path} -V", puts_output: false)).to match(/\d\.\d\.\d/)
    expect(
      process("#{gitrflow_path}", puts_output: false, expected_exit_status: 1)
    ).to match(/^    -V, --version/m)
  end
end