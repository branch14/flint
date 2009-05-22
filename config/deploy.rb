set :application, "flint"

set :scm,         :git
set :deploy_via,  :copy
set :synchronous_connect, true
set :repository,  File.join(File.dirname(__FILE__), '..')

set :deploy_to, "/home/rails/#{application}"

set :user, 'www-data'
set :one4all, '192.168.178.24'

role :app, one4all
role :web, one4all
role :db,  one4all, :primary => true

ssh_options[:keys] = %w(/home/phil/.ssh/id_rsa)


# %%% ## set :application, "vxs"
# %%% ## 
# %%% ## set :scm,         :git
# %%% ## #set :deploy_via,  :remote_cache
# %%% ## set :deploy_via,  :copy
# %%% ## #set :git_shallow_clone,  1
# %%% ## set :synchronous_connect, true
# %%% ## 
# %%% ## #set :copy_strategy, :export
# %%% ## 
# %%% ## #ssh_options[:paranoid] = false
# %%% ## ssh_options[:keys] = "/home/phil/.ssh/id_dsa"
# %%% ## 
# %%% ## set :repository,  File.join(File.dirname(__FILE__), '..')
# %%% ## #set :repository,  "/home/phil/ruby/rails/vxs"
# %%% ## set :deploy_to,   "/home/_rails/#{application}"
# %%% ## 
# %%% ## #set :user,        "www-data"
# %%% ## #set :runner,      "www-data"
# %%% ## #set :use_sudo,    false
# %%% ## 
# %%% ## set :domain,      "adam.hfg-karlsruhe.de"
# %%% ## role :app,        domain
# %%% ## role :web,        domain
# %%% ## role :db,         domain, :primary => true
# %%% ## 
# %%% ## # as of http://modrails.com/documentation/Users%20guide.html#_redeploying_restarting_the_ruby_on_rails_application
# %%% ## namespace :deploy do
# %%% ##   task :restart do
# %%% ##     run "touch #{deploy_to}/current/tmp/restart.txt"
# %%% ##   end
# %%% ## end
# %%% 
# %%% 
# %%% set :application, 'vxs'
# %%% 
# %%% set :scm, :git
# %%% set :deploy_via, :remote_cache
# %%% set :repository, 'git@jandl:vxs.git'
# %%% 
# %%% ssh_options[:paranoid] = false
# %%% 
# %%% set :domain, 'jandl'
# %%% role :app, domain
# %%% role :web, domain
# %%% role :db, domain, :primary => true
# %%% 
# %%% set :user, 'www-data'
# %%% 
# %%% # as of http://modrails.com/documentation/Users%20guide.html#_redeploying_restarting_the_ruby_on_rails_application
# %%% namespace :deploy do
# %%%   task :restart, :roles => :app, :except => { :no_release => true } do
# %%%     top.deprec.mongrel.restart
# %%%   end
# %%% end
