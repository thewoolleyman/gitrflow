def validate_options(options)
  valid_options = [
    :expected_exit_status,
    :include_output_in_exception,
    :puts_output,
  ]
  invalid_options = (options.keys - valid_options)
  fail "Invalid option(s) '#{invalid_options.join(', ')}' given.  " \
          "Valid options are: #{valid_options.join(', ')}" unless invalid_options.empty?
end

def get_output(options, stdout_and_stderr)
  output = ''
  while (line = stdout_and_stderr.gets)
    puts line unless options[:puts_output] == false
    output += line
  end
  output
end

def handle_exit_status(cmd, options, output, wait_thr)
  expected_exit_status = options[:expected_exit_status] || 0
  exit_status = wait_thr.value
  return if exit_status.exitstatus == expected_exit_status
  exit_status_msg =
    if expected_exit_status == 0
      ''
    else
      " (expected #{expected_exit_status})"
    end

  exception_message = "Command failed, #{exit_status}#{exit_status_msg}. " \
    "Command: `#{cmd}`."
  if options[:include_output_in_exception]
    exception_message += " Command Output: \"#{output}\""
  end
  fail exception_message
end

def process(cmd, options={})
  validate_options(options)
  Open3.popen2e(cmd) do |_, stdout_and_stderr, wait_thr|
    output = get_output(options, stdout_and_stderr)

    handle_exit_status(cmd, options, output, wait_thr)
    output
  end
end
