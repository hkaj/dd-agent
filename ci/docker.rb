require './ci/common'

namespace :ci do
  namespace :docker do |flavor|
    task before_install: ['ci:common:before_install']

    task install: ['ci:common:install'] do
      sh %(docker pull redis:latest)
      sh %(docker pull mongodb:latest)
      sh %(docker run -d --name redis -p 6379:6379 redis)
      sh %(docker run -d --name mongodb -p 27017:27017 mongodb)
    end

    task before_script: ['ci:common:before_script'] do
    end

    task script: ['ci:common:script'] do
      this_provides = [
        'docker'
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task before_cache: ['ci:common:before_cache']

    task cache: ['ci:common:cache']

    task cleanup: ['ci:common:cleanup'] do
      sh %(docker kill redis)
      sh %(docker rm redis)
      sh %(docker kill mongodb)
      sh %(docker rm mongodb)
    end

    task :execute do
      exception = nil
      begin
        %w(before_install install before_script
           script before_cache cache).each do |t|
          Rake::Task["#{flavor.scope.path}:#{t}"].invoke
        end
      rescue => e
        exception = e
        puts "Failed task: #{e.class} #{e.message}".red
      end
      if ENV['SKIP_CLEANUP']
        puts 'Skipping cleanup, disposable environments are great'.yellow
      else
        puts 'Cleaning up'
        Rake::Task["#{flavor.scope.path}:cleanup"].invoke
      end
      fail exception if exception
    end
  end
end
