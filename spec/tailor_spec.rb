require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerTailor do
    it 'should be a plugin' do
      expect(Danger::DangerTailor.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.tailor
      end

      it 'Parses JSON with warnings and no errors' do
        warning_path = File.expand_path('../warnings.json', __FILE__)
        @my_plugin.report(warning_path)
        expect(@dangerfile.status_report[:errors]).to eq([])
        expect(@dangerfile.status_report[:warnings].length).to be == 5
        expect(@dangerfile.status_report[:markdowns]).to eq([])
      end

      it 'Displays a summary message for warnings' do
        warning_path = File.expand_path('../warnings.json', __FILE__)
        @my_plugin.report(warning_path)
        # puts @dangerfile.status_report
        expect(@dangerfile.status_report[:messages]).to eq(["Tailor Summary: Analyzed 3 files. Found 5 violations. 5 Warnings and 0 Errors."])
      end

      it 'Displays a properly formatted warning message' do
        warning_path = File.expand_path('../warnings.json', __FILE__)
        @my_plugin.report(warning_path)
        expect(@dangerfile.status_report[:warnings][0]).to eq("/Users/Patrick/Developer/CITest-ios/CITest/AppDelegate.swift:#21 -> terminating-newline - File should terminate with exactly one newline character ('\\n')")
      end
    end
  end
end
