require_relative 'spec_helper'

describe 'start' do
  it 'creates the specified feature branch' do
    pending 'TODO:'
    branch = 'feature/feature1'
    out = process("git #{gitrflow_path} feature start #{branch}")
    expect(out).to eq('created feature branch feature/feature1')
  end
end
