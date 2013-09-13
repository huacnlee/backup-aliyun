## Backup to Aliyun OSS

此 Gem 是 [Backup](https://github.com/meskyanichi/backup) 的辅助插件，目的是让 Backup 支持存储到 [Aliyun OSS](http://oss.aliyun.com)。

## 安装

```bash
$ gem install backup-aliyun
```
## 配置

你需要在你的 Backup models 文件里面单独引用 `backup-aliyun`，比如：

~/Backup/models/foo.rb

```ruby
require "backup-aliyun" # 引用 backup-aliyun

Backup::Model.new(:foo, 'Description for foo') do

  # 配置阿里云 OSS 作为备份存储方式
  store_with Aliyun do |aliyun|
    aliyun.access_key_id = 'my_access_id'
    aliyun.access_key_secret = 'my_access_key'
    aliyun.bucket = 'bucket-name'
    aliyun.path = '/path/to/my/backups'
    aliyun.keep = 10
  end
end
```

然后你就可以用 Backup 把你的备份文件存储到 Aliyun OSS 上面了。

至于 Backup 的使用方法请参见 [Backup](https://github.com/meskyanichi/backup) 的文档。
