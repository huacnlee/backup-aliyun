# encoding: utf-8

require File.expand_path('../spec_helper.rb', __FILE__)

describe Backup::Storage::Aliyun do
  let(:model)   { Backup::Model.new(:test_trigger, 'test label') }
  let(:storage) do
    Backup::Storage::Aliyun.new(model) do |db|
      db.access_key_id       = ENV['ALIYUN_ACCESS_ID'] || 'my_access_id'
      db.access_key_secret   = ENV['ALIYUN_ACCESS_KEY'] || '123456'
      db.bucket              = ENV['ALIYUN_BUCKET'] || 'carrierwave-aliyun-test'
      db.area                = ENV['ALIYUN_AREA'] || 'cn-hangzhou'
      db.keep                = 5
    end
  end

  it 'should be a subclass of Storage::Base' do
    Backup::Storage::Aliyun.
      superclass.should == Backup::Storage::Base
  end

  describe '#initialize' do
    after { Backup::Storage::Aliyun.clear_defaults! }

    it 'should load pre-configured defaults through Base' do
      Backup::Storage::Aliyun.any_instance.expects(:load_defaults!)
      storage
    end

    it 'should pass the model reference to Base' do
      storage.instance_variable_get(:@model).should == model
    end

    it 'should pass the storage_id to Base' do
      storage = Backup::Storage::Aliyun.new(model, 'my_storage_id')
      storage.storage_id.should == 'my_storage_id'
    end

    context 'when no pre-configured defaults have been set' do
      it 'should use the values given' do
        storage.access_key_id.should      == ENV['ALIYUN_ACCESS_ID'] || 'my_access_id'
        storage.access_key_secret.should   == ENV['ALIYUN_ACCESS_KEY'] || '123456'
        storage.bucket.should  == ENV['ALIYUN_BUCKET'] || 'carrierwave-aliyun-test'
        storage.area.should  == ENV['ALIYUN_AREA'] || 'cn-hangzhou'
        storage.path.should         == 'backups'

        storage.storage_id.should be_nil
        storage.keep.should       == 5
      end

      it 'should use default values if none are given' do
        storage = Backup::Storage::Aliyun.new(model)
        storage.access_key_id.should      be_nil
        storage.access_key_secret.should   be_nil
        storage.bucket.should       be_nil
        storage.area.should == 'cn-hangzhou'
        storage.path.should == 'backups'

        storage.storage_id.should be_nil
        storage.keep.should       be_nil
      end
    end # context 'when no pre-configured defaults have been set'

    context 'when pre-configured defaults have been set' do
      before do
        Backup::Storage::Aliyun.defaults do |s|
          s.access_key_id      = 'some_api_key'
          s.access_key_secret   = 'some_api_secret'
          s.bucket  = 'some_bucket'
          s.path         = 'some_path'
          s.keep         = 15
        end
      end

      it 'should use pre-configured defaults' do
        storage = Backup::Storage::Aliyun.new(model)

        storage.access_key_id.should      == 'some_api_key'
        storage.access_key_secret.should   == 'some_api_secret'
        storage.bucket.should  == 'some_bucket'
        storage.path.should         == 'some_path'

        storage.storage_id.should be_nil
        storage.keep.should       == 15
      end

      it 'should override pre-configured defaults' do
        storage = Backup::Storage::Aliyun.new(model) do |s|
          s.access_key_id      = 'new_api_key'
          s.access_key_secret   = 'new_api_secret'
          s.bucket  = 'new_bucket'
          s.path         = 'new_path'
          s.keep         = 10
        end

        storage.access_key_id.should      == 'new_api_key'
        storage.access_key_secret.should   == 'new_api_secret'
        storage.bucket.should  == 'new_bucket'
        storage.path.should         == 'new_path'

        storage.storage_id.should be_nil
        storage.keep.should       == 10
      end
    end # context 'when pre-configured defaults have been set'
  end # describe '#initialize'

  describe '#transfer!' do
    let(:client) { mock }
    let(:package) { mock }
    let(:file) { mock }
    let(:s) { sequence '' }

    before do
      storage.instance_variable_set(:@package, package)
      storage.stubs(:storage_name).returns('Storage::Aliyun')
      Backup::Config.stubs(:tmp_path).returns('/local/path')
      storage.stubs(:client).returns(client)
      file.stubs(:read).returns("foo")
    end

    it 'should transfer the package files' do

      storage.expects(:remote_path_for).in_sequence(s).with(package).
          returns('remote/path')
      package.stubs(:filenames).returns(["backup.tar.enc-aa","backup.tar.enc-ab"])
      # first yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::Aliyun uploading 'remote/path/backup.tar.enc-aa'..."
      )
      File.expects(:open).in_sequence(s).with(
        File.join('/local/path', 'backup.tar.enc-aa'), 'r'
      ).yields(file)
      client.expects(:bucket_create_object).in_sequence(s).with(
        File.join('remote/path', 'backup.tar.enc-aa'), file, {}
      )
      # second yield
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::Aliyun uploading 'remote/path/backup.tar.enc-ab'..."
      )
      File.expects(:open).in_sequence(s).with(
        File.join('/local/path', 'backup.tar.enc-ab'), 'r'
      ).yields(file)
      client.expects(:bucket_create_object).in_sequence(s).with(
        File.join('remote/path', 'backup.tar.enc-ab'), file, {}
      )

      storage.send(:transfer!)
    end
  end # describe '#transfer!'

  describe '#remove!' do
    let(:package) { mock }
    let(:client) { mock }
    let(:s) { sequence '' }

    before do
      storage.stubs(:storage_name).returns('Storage::Aliyun')
      storage.stubs(:client).returns(client)
    end

    it 'should remove the package files' do
      storage.expects(:remote_path_for).in_sequence(s).with(package).
          returns('remote/path')
      # after both yields
      Backup::Logger.expects(:info).in_sequence(s).with(
        "Storage::Aliyun removing 'remote/path'..."
      )
      client.expects(:bucket_delete_object).in_sequence(s).with('remote/path')

      storage.send(:remove!, package)
    end
  end # describe '#remove!'


end
