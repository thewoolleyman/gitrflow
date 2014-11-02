require 'rspec'
require 'open3'
require_relative 'process_helper'

# Rspec helper methods
module SpecHelper
  include ProcessHelper

  def gitrflow_path
    File.expand_path('../../gitrflow', __FILE__)
  end
end
include SpecHelper
