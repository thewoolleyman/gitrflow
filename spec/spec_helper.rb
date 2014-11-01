require 'open3'

def gitrflow_path
  File.expand_path("../../gitrflow", __FILE__)
end

def process(cmd, options={})
  valid_options = [:puts_output, :include_output_in_exception]
  invalid_options = (options.keys - valid_options)
  raise "Invalid option(s) '#{invalid_options.join(', ')}' given.  Valid options are: #{valid_options.join(', ')}" unless invalid_options.empty?
  Open3.popen2e(cmd) do |stdin, stdout_and_stderr, wait_thr|
    output = ''
    while line = stdout_and_stderr.gets
      puts line unless options[:puts_output] == false
      output += line
    end

    exit_status = wait_thr.value
    unless exit_status.success?
      exception_message = "Command failed, #{exit_status.to_s}. Command: `#{cmd}`."
      if options[:include_output_in_exception]
        exception_message += " Command Output: \"#{output}\""
      end
      raise exception_message
    end
    output
  end
end