require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler/setup'
require 'backup'
require 'backup-aliyun'


require 'rspec/autorun'
RSpec.configure do |config|
  ##
  # Use Mocha to mock with RSpec
  config.mock_with :mocha

  ##
  # Example Helpers
  # config.include Backup::ExampleHelpers

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true


  config.before(:each) do
    # ::FileUtils will always be either SandboxFileUtils or FileUtils::NoWrite.
    # SandboxFileUtils.deactivate!(:noop)

    # prevent system calls
    Backup::Utilities.stubs(:gnu_tar?).returns(true)
    Backup::Utilities.stubs(:utility)
    Backup::Utilities.stubs(:run)
    Backup::Pipeline.any_instance.stubs(:run)

    Backup::Utilities.send(:reset!)
    Backup::Config.send(:reset!)
    # Logger only queues messages received until Logger.start! is called.
    Backup::Logger.send(:reset!)
  end
end