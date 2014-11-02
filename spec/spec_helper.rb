require 'rspec'
require 'open3'
require_relative 'process_helper'

def gitrflow_path
  File.expand_path('../../gitrflow', __FILE__)
end
