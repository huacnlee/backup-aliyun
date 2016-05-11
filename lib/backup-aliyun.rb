require "backup"

Backup::Storage.send(:autoload, :Aliyun, File.join(File.dirname(__FILE__), "backup/storage/aliyun"))
