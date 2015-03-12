require "heroku/command/base"

# lists releases for all your heroku remotes
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
        begin
          # capture stdout
          Thread.current[:output] = []

          # this is simply copied from 3.9.6/lib/heroku/command/releases.rb
          # https://github.com/heroku/heroku/blob/master/lib/heroku/command/releases.rb

          # ---------
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
          # ---------

          # capture stdout
          output[remote] = Thread.current[:output].join
        rescue
          output[remote] = "Something went wrong fetching releases for #{app}."
        end
      end
    end.map(&:join)

    output.sort.each do |remote, output|
      puts output
      puts
    end
  end

  # rels:info
  #
  # list releases:info for all heroku remotes
  # useful if you have production and staging remotes
  # and want to see information about all of them
  # without typing stupid app names
  #
  def info
    validate_arguments!

    remotes = self.class.heroku_remotes

    # trigger 'No app specified' message
    remotes.push ['--app', app] if remotes.empty? or options[:app]

    output = {}
    remotes.map do |remote|
      Thread.new(remote) do |remote, app|
        begin
          # capture stdout
          Thread.current[:output] = []

          release = api.get_releases(app).body.sort_by do |release|
            release["name"][1..-1].to_i
          end.last["name"]

          # display_header("#{app}")
          puts "##### #{app} #####\n"

          # this is simply copied from 3.9.6/lib/heroku/command/releases.rb
          # https://github.com/heroku/heroku/blob/master/lib/heroku/command/releases.rb

          # ---------
          release_data = api.get_release(app, release).body

          data = {
            'By'     => release_data['user'],
            'Change' => release_data['descr'],
            'When'   => time_ago(release_data["created_at"])
          }

          unless release_data['addons'].empty?
            data['Addons'] = release_data['addons']
          end


          styled_header("Release #{release}")
          styled_hash(data)

          display

          styled_header("#{release} Config Vars")
          unless release_data['env'].empty?
            if options[:shell]
              release_data['env'].keys.sort.each do |key|
                display("#{key}=#{release_data['env'][key]}")
              end
            else
              styled_hash(release_data['env'])
            end
          else
            display("#{release} has no config vars.")
          end
          # ---------

          # capture stdout
          output[remote] = Thread.current[:output].join
        rescue
          output[remote] = "Something went wrong fetching releases for #{app}."
        end
      end
    end.map(&:join)

    output.sort.each do |remote, output|
      puts output
      puts
    end
  end

  # rels:version
  #
  # prints version of rels (v0.3)
  #
  def version
    puts "v0.3"
  end

private

  def self.heroku_remotes
    `git remote -v 2>/dev/null`.scan(/^(.+)\t.+heroku\.com:(.+)\.git/).uniq
  end

  def puts(*arg)
    if Thread.current[:output].nil?
      super *arg
    else
      Thread.current[:output].push "#{arg.first}\n"
    end
  end

  def print(*arg)
    if Thread.current[:output].nil?
      super *arg
    else
      Thread.current[:output].push arg.first
    end
  end

end
