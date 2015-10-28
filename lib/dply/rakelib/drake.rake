require_relative '../ext/string'

def load_app_rakefile
  @app_rakefile_loaded ||= begin
    load './Rakefile'
  end
end

namespace :drake do
  desc "task runner to optionally invoke tasks"
  task :runner do
    runner_tasks = ENV["runner_tasks"] || ""
    optional = ENV["runner_optional"]
    app_task = ENV["runner_app_task"]

    load_app_rakefile if app_task
    tasks = runner_tasks.split(',')
    task = tasks.find { |i| Rake::Task.task_defined? i}

    if task
      puts "#{"\u2219".bold.yellow} #{task}"
      Rake::Task[task].invoke
    else
      if optional
        puts "#{"WARN".yellow} any of the tasks not found: #{tasks}"
      else
        abort "#{"ERROR".red} any of the required tasks not defined: #{tasks}"
      end
    end
  end
end

Dir.glob('dply/*.rake').each { |r| load r}
