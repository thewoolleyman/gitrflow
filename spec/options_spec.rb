require_relative 'spec_helper'

describe 'options' do
  it 'prints error if no options are passed' do
    begin
      expect(process("#{gitrflow_path}", puts_output: false)).to match(/Usage: /m)
    rescue => e
      expect(e.message).to match(/Command failed/)
    end
  end

  it '--version' do
    expect(process("#{gitrflow_path} --version")).to match(/\d\.\d\.\d/)
  end
end