module Danger
  # Shows the build errors, warnings and violations generated from Tailor.
  # You need [Tailor](https://tailor.sh) installed and generating a json file
  # to use this plugin
  #
  # @example Showing summary
  #
  #     tailor -f json MyProject/ > tailor.json
  #     danger-tailor.report 'tailor.json'
  #
  # @example Filter out the pods before analyzing
  #
  #     danger-tailor.ignored_files = '**/Pods/**'
  #     danger-tailor.report 'tailor.json'
  #
  # @see  IntrepidPursuits/danger-tailor
  # @tags xcode, swift, tailor, lint, format, xcodebuild
  #
  class DangerTailor < Plugin
    # The project root, which will be used to make the paths relative.
    # Defaults to `pwd`.
    # @return   [String] project_root value
    attr_accessor :project_root

    # A globbed string or array of strings which should match the files
    # that you want to ignore warnings on. Defaults to nil.
    # An example would be `'**/Pods/**'` to ignore warnings in Pods that your
    # project uses.
    #
    # @return   [[String]] ignored-files
    attr_accessor :ignored_files

    # Defines if the test summary will be sticky or not.
    # Defaults to `false`.
    # @return   [Boolean] sticky
    attr_accessor :sticky_summary

    def project_root
      root = @project_root || Dir.pwd
      root += '/' unless root.end_with? '/'
      root
    end

    def ignored_files
      [@ignored_files].flatten.compact
    end

    def sticky_summary
      @sticky_summary || false
    end

    # Reads a file with JSON Xcode summary and reports it.
    #
    # @param    [String] file_path Path for Tailor summary in JSON format.
    # @return   [void]
    def report(file_path)
      raise 'Summary file not found' unless File.file?(file_path)
      tailor_summary = JSON.parse(File.read(file_path), symbolize_names: true)
      run_summary(tailor_summary)
    end

    private

    def run_summary(tailor_summary)
      # Output the tailor summary
      message(summary_message(tailor_summary), sticky: sticky_summary)

      # Parse the file violations
      parse_files(tailor_summary)
    end

    def summary_message(tailor_summary)
      summary = tailor_summary[:summary]
      m = "Tailor Summary: Analyzed #{summary[:analyzed]} files. Found #{summary[:violations]} violations. #{summary[:warnings]} Warnings and #{summary[:errors]} Errors."
      m << " Skipped #{summary[:skipped]} files." unless summary[:skipped].zero?
      m
    end

    # A method that takes the tailor summary, and for each file, parses out
    # any violations found.
    def parse_files(tailor_summary)
      tailor_summary[:files].each do |f|
        parse_violations(f[:path], f[:violations])
      end
    end

    # A method that takes a file path, and an array of tailor violation objects,
    # parses the violation, and calls the appropriate Danger method
    def parse_violations(file_path, violations)
      violations.each do |v|
        severity = v[:severity]
        message = format_violation(file_path, v)

        if severity == 'warning'
          warn(message, sticky: false)
        elsif severity == 'error'
          fail(message, sticky: false)
        end
      end
    end

    # A method that returns a formatted string for a violation
    # @return String
    #
    def format_violation(file_path, violation)
      "#{file_path}:#L#{violation[:location][:line]} -> #{violation[:rule]} - #{violation[:message]}"
    end
  end
end
