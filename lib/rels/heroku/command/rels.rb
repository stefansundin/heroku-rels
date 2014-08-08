require "heroku/command/base"

# MIT License, same as heroku-cli

class Heroku::Command::Rels < Heroku::Command::Base

  # rels
  #
  # list releases for all heroku remotes
  # useful if you have production and staging remotes
  # and want to see when all concerned were deployed
  # without typing stupid app names
  #
  def index
    validate_arguments!
    release_count = options[:num].nil? ? 10 : options[:num].to_i 

    remotes = self.class.heroku_remotes

    # trigger 'No app specified' message
    remotes.push ['--app', app] if remotes.empty? or options[:app]

    output = {}
    remotes.map do |remote|
      Thread.new(remote) do |remote, app|
        # capture stdout
        Thread.current[:output] = []

        # this is simply copied from 3.9.6/lib/heroku/command/releases.rb
        # https://github.com/heroku/heroku/blob/master/lib/heroku/command/releases.rb

        releases_data = api.get_releases(app).body.sort_by do |release|
          release["name"][1..-1].to_i
        end.reverse.slice(0, release_count)

        unless releases_data.empty?
          releases = releases_data.map do |release|
            [
              release["name"],
              truncate(release["descr"], 40),
              release["user"],
              time_ago(release['created_at'])
            ]
          end

          styled_header("#{app} Releases")
          styled_array(releases, :sort => false)
        else
          display("#{app} has no releases.")
        end

        # capture stdout
        output[remote] = Thread.current[:output].join "\n"
      end
    end.map(&:join)

    output.sort.each do |remote, output|
      puts output
      puts
    end
  end

private

  def self.heroku_remotes
    `git remote -v`.scan(/^(.+)\t.+heroku\.com:(.+)\.git/).uniq
  end

  def puts(*arg)
    if Thread.current[:output].nil?
      super *arg
    else
      Thread.current[:output].push arg
    end
  end

end
