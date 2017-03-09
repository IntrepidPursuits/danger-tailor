module Danger
  # Shows the build errors, warnings and violations generated from Tailor.
  # You need [Tailor](https://tailor.sh) installed and generating a json file
  # to use this plugin
  #
  # @see  IntrepidPursuits/danger-tailor
  # @tags xcode, swift, tailor, lint, format, xcodebuild
  #
  class DangerTailor < Plugin

    # The project root, which will be used to make the paths relative.
    # Defaults to `pwd`.
    # @param    [String] value
    # @return   [String]
    attr_accessor :project_root

    # A globbed string or array of strings which should match the files
    # that you want to ignore warnings on. Defaults to nil.
    # An example would be `'**/Pods/**'` to ignore warnings in Pods that your project uses.
    #
    # @param    [String or [String]] value
    # @return   [[String]]
    attr_accessor :ignored_files

    # Defines if the test summary will be sticky or not.
    # Defaults to `false`.
    # @param    [Boolean] value
    # @return   [Boolean]
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
      if File.file?(file_path)
        tailor_summary = JSON.parse(File.read(file_path), symbolize_names: true)
        run_summary(tailor_summary)
      else
        fail 'summary file not found'
      end
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
      message = "Tailor Summary: Analyzed #{summary[:analyzed]} files. Found #{summary[:errors]} errors and #{summary[:violations]} violations."
      message += " #{summary[:warnings]} Warnings." unless summary[:warnings] == 0
      message += " Skipped #{summary[:skipped]} files." unless summary[:skipped] == 0
      message
    end

    # A method that takes the tailor summary, and for each file, parses out
    # any violations found.
    def parse_files(tailor_summary)
      tailor_summary[:files].each { |f| parse_violations(f[:path], f[:violations]) }
    end

    # A method that takes a file path, and an array of tailor violation objects,
    # parses the violation, and calls the appropriate Danger method
    def parse_violations(file_path, violations)
      violations.each { |v|
        severity = violation[:severity]
        message = format_violation(file_path, v)

        if severity == "warning"
          warn(message, sticky: false)
        elsif severity == "error"
          fail(message, sticky: false)
        end
      }
    end

    # A method that returns a formatted string for a violation
    # @return String
    #
    def format_violation(file_path, violation)
      "#{file_path} - Line #{violation[:location][:line]} -> #{violation[:rule]} - #{violation[:message]}"
    end

  end
end
