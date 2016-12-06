require 'aliyun/oss'

module Backup
  module Storage
    class Aliyun < Base
      include Storage::Cycler

      attr_accessor :bucket, :area, :access_key_id, :access_key_secret, :path

      def initialize(model, storage_id = nil, &block)
        super(model, storage_id)

        @path ||= 'backups'
        @area ||= 'cn-hangzhou'

        instance_eval(&block) if block_given?
      end

      private

      def client
        return @client if defined? @client
        opts = {
          host: "oss-#{self.area}.aliyuncs.com",
          bucket: self.bucket
        }
        @client = ::Aliyun::Oss::Client.new(self.access_key_id, self.access_key_secret, opts)
        @client
      end

      def transfer!
        remote_path = remote_path_for(@package)

        @package.filenames.each do |filename|
          src = File.join(Config.tmp_path, filename)
          dest = File.join(remote_path, filename)
          Logger.info "#{storage_name} uploading '#{ dest }'..."
          File.open(src, 'r') do |file|
            client.bucket_create_object(dest, file, {})
          end
        end
      end

      def remove!(package)
        remote_path = remote_path_for(package)
        Logger.info "#{storage_name} removing '#{remote_path}'..."
        client.bucket_delete_object(remote_path)
      end
    end
  end
end
