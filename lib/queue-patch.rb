# encoding: UTF-8

require 'uri'

module QueuePatch

  PATCH_LIST_LOCATION = File.expand_path('~/Dropbox/Elements/patch-queue.md')

  URL_MATCH = %r@((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))@.freeze
  TICKET_MATCH = /((CHEF|OHAI)\-[\d]{2,})/i
  PULL_REQ = /([\S]+) wants someone to pull from (([^:\s]+):([^:\s]+))/

  class PatchData

    attr_reader :urls
    attr_reader :tickets
    attr_reader :github_user
    attr_reader :github_branch

    def initialize(text)
      @urls = text.scan(URL_MATCH).map { |match| match[0] }.uniq
      @tickets = text.scan(TICKET_MATCH).map { |match| match[0] }.uniq
      if github_data = text.scan(PULL_REQ)[0]
        @github_user = github_data[0]
        @github_branch = github_data[3]
      end
    end

    def github_url
      @github_url ||= urls.find { |u| u =~ /github/ }
    end

    def project
      @project ||= (github_url && github_url[%r{https?\://github.com/opscode/([^/]+)/pull/.+}, 1])
    end

    def pull_request_number
      @pull_request_number ||= (github_url && github_url[%r{https?\://github.com/opscode/[^/]+/pull/([\d]+)}, 1])
    end

    def to_md
      md = "* "
      unless tickets.empty?
        md << "[#{tickets.first}](http://tickets.opscode.com/browse/#{tickets.first}) "
      end
      if github_url && pull_request_number && project
        md << "[pull request #{project}-#{pull_request_number}](#{github_url}) "
      end
      if github_user && github_branch && project
        md << "[#{github_user}/#{github_branch}](https://github.com/#{github_user}/#{project}/commits/CHEF-1959)"
      end
      md
    end

  end

  class QueueList

    def <<(patch_data)
      File.open(PATCH_LIST_LOCATION, 'a') do |f|
        f.puts(patch_data.to_md)
      end
    end

    def to_s
      IO.read(PATCH_LIST_LOCATION)
    end

  end

  class CLI

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      case ARGV.first
      when "add"
        QueueList.new << PatchData.new(IO.read)
      when "paste"
        QueueList.new << PatchData.new(`pbpaste`)
      when "list"
        puts QueueList.new.to_s
      when "edit"
        exec "vim #{PATCH_LIST_LOCATION}"
      when "show"
        require 'tmpdir'
        require 'rubygems'
        require 'rdiscount'

        html_path = File.expand_path("patch-queue.html", Dir.tmpdir)

        File.open(html_path, "w+") do |html_file|
          html_file.write(RDiscount.new(IO.read(PATCH_LIST_LOCATION)).to_html)
        end

        exec("open #{html_path}")
      when "linkify"
        IO.readlines(PATCH_LIST_LOCATION).each do |line|
          if line =~ /^\*/
            puts PatchData.new(line).to_md
          else
            puts line
          end
        end
      else
        puts "Usage: queue-patch add|paste|list|edit|show|linkify"
        exit 1
      end
      exit 0
    end
  end

end