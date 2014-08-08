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

    apps = self.class.heroku_apps
    apps = [app] if apps.empty? # trigger 'No app specified' message

    apps.each do |app|

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
    end
  end

private

  def self.heroku_apps
    `git remote -v`.scan(/heroku\.com:(.+)\.git/).uniq
  end

end
