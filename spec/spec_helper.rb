require 'rspec'
require 'open3'
require_relative 'process_helper'

# Rspec helper methods
module SpecHelper
  include ProcessHelper

  def path_with_gitrflow
    "#{File.expand_path('../../', __FILE__)}:$PATH"
  end

  def gitrflow_path
    File.expand_path('../../git-rflow', __FILE__)
  end

  def gitrflow_cmd
    "PATH=#{path_with_gitrflow} git rflow"
  end
end
include SpecHelper
