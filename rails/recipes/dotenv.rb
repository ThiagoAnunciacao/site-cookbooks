include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  template "#{deploy[:deploy_to]}/shared/.env" do
    cookbook 'rails'
    source "dotenv.erb"
    mode "00755"
    group deploy[:group]
    owner deploy[:user]

    command "rm -f #{deploy[:deploy_to]}/current/.env; ln -s #{deploy[:deploy_to]}/.env #{deploy[:deploy_to]}/shared/.env"

    notifies :run, "execute[restart Rails app #{application}]"
  end
end