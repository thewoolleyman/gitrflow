# Helper for executing shell commands
module ProcessHelper
  def valid_option_pairs
    [
      [
        :expected_exit_status,
        :exp_rc,
      ],
      [
        :include_output_in_exception,
        :out_ex,
      ],
      [
        :puts_output,
        :out,
      ]
    ]
  end

  def valid_options
    valid_option_pairs.flatten
  end

  def validate_options(options)
    invalid_options = (options.keys - valid_options)
    fail "Invalid option(s) '#{invalid_options.join(', ')}' given.  " \
          "Valid options are: #{valid_options.join(', ')}" unless invalid_options.empty?
    valid_option_pairs.each do |pair|
      long, short = pair
      fail "Cannot specify both '#{long}' and '#{short}'" if options[long] && options[short]
    end
  end

  def convert_short_options(options)
    valid_option_pairs.each do |pair|
      long, short = pair
      options[long] = options[short] if options[short]
    end
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
    options = options.dup
    validate_options(options)
    convert_short_options(options)
    Open3.popen2e(cmd) do |_, stdout_and_stderr, wait_thr|
      output = get_output(options, stdout_and_stderr)

      handle_exit_status(cmd, options, output, wait_thr)
      output
    end
  end

  alias_method :run, :process
end
