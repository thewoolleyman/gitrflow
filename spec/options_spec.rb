require_relative 'spec_helper'

describe 'options' do
  it 'prints error if no options are passed' do
    expect(
      process("#{gitrflow_path}", puts_output: false, expected_exit_status: 1)
    ).to match(/Usage: /m)
  end

  it '--version' do
    expect(process("#{gitrflow_path} --version")).to match(/\d\.\d\.\d/)
  end
end