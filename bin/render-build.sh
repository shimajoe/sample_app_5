#https://qiita.com/ysk91_engineer/items/b7db950f4739fa896f57 より
#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate