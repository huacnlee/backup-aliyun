## Backup to Aliyun OSS

此 Gem 是 [Backup](https://github.com/meskyanichi/backup) 的辅助插件，目的是让 Backup 支持存储到 [Aliyun OSS](http://oss.aliyun.com)。

> 此项目不再维护，推荐我用 Go 写的 backup 替代工具 gobackup，内置 OSS 存储方式 https://github.com/huacnlee/gobackup

[![Build Status](https://travis-ci.org/huacnlee/backup-aliyun.svg?branch=master)](https://travis-ci.org/huacnlee/backup-aliyun)

## 安装

```bash
$ gem install backup-aliyun
```

## 配置

你需要在你的 Backup models 文件里面单独引用 `backup-aliyun`，比如：

~/Backup/models/foo.rb

```ruby
require "backup-aliyun" # 引用 backup-aliyun

Model.new(:foo, 'Description for foo') do
  # 配置阿里云 OSS 作为备份存储方式, 注意，Aliyun 这个地方一定要打引号
  store_with "Aliyun" do |aliyun|
    aliyun.access_key_id     = 'my_access_id'
    aliyun.access_key_secret = 'my_access_key'
    aliyun.bucket            = 'bucket-name'
    # 修改对应的 OSS 所在区域，默认 cn-hangzhou
    aliyun.area              = 'cn-hangzhou'
    aliyun.path              = '/path/to/my/backups'
    aliyun.keep              = 10
  end
end
```

然后你就可以用 Backup 把你的备份文件存储到 Aliyun OSS 上面了。

至于 Backup 的使用方法请参见 [Backup](https://github.com/meskyanichi/backup) 的文档。
