# config/deploy/production.rb
server '139.59.114.156', user: 'root', roles: %w{web app db}

set :rails_env, :production
set :branch, :main # 프로덕션 배포에 사용할 브랜치

# If you're using password authentication, you might need to uncomment and configure this
# set :ssh_options, {
#   forward_agent: true,
#   auth_methods: %w(password),
#   # password: 'your_password' # WARNING: Storing password directly in config is not recommended. Use SSH keys.
# }