shared_dir = File.absolute_path(File.join(__FILE__, '..', '..', '..', '..', 'shared'))

worker_processes 3
timeout 30

listen      File.join(shared_dir, 'tmp', 'sockets', 'unicorn.sock'), :backlog => 64
pid         File.join(shared_dir, 'tmp', 'pids', 'unicorn.pid')
stderr_path File.join(shared_dir, 'log', 'unicorn.stderr.log')
stdout_path File.join(shared_dir, 'log', 'unicorn.stdout.log')

preload_app true

# DSA - Unicorn stashes its startup command for use on restarts, so it _will load old versions or fail to load newer ones
#       see http://unicorn.bogomips.org/Sandbox.html
Unicorn::HttpServer::START_CTX[0] = "/var/rails/sample_app/current/bin/unicorn"

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "/var/rails/sample_app/current/Gemfile"
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = File.join(shared_dir, 'tmp', 'pids', 'unicorn.pid.oldbin')
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # already killed
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  Resque.redis.client.reconnect
end