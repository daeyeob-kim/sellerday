# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "sellerday" # 애플리케이션 이름
set :repo_url, "git@github.com:daeyeob-kim/sellerday.git" # GitHub 저장소 URL

# Default branch is :master
set :branch, :main # main 브랜치 사용

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/sellerday" # 서버에 배포될 경로

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# config/database.yml, config/master.key, .env 파일은 서버에 직접 생성하거나 업로드할 것이므로 여기에 추가합니다.
append :linked_files, "config/database.yml", "config/master.key", ".env"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually confirming clear/clean tasks when pulling from remote
# ask :confirm_clear, "Are you sure you want to clear the remote cache?"

# Puma specific settings
set :puma_threads,    [4, 16]
set :puma_workers,    0 # 0으로 설정하면 워커를 사용하지 않고 스레드만 사용

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log,  "#{shared_path}/log/puma_error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Capistrano 3.x에서 Rails 5 이상 사용 시 필요

# rbenv specific settings
set :rbenv_type, :user # rbenv 설치 방식에 따라 :user 또는 :system
set :rbenv_ruby, '3.1.4' # 프로젝트 Ruby 버전과 일치

# Custom tasks that run after deploy:finished
namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end