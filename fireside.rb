require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'camping'

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# An in-memory Sqlite3 connection:
DataMapper.setup(:default, 'sqlite::memory:')

Camping.goes :Fireside

module Fireside::Models
  class Post
    include DataMapper::Resource

     property :id,         Serial    # An auto-increment integer key
     property :title,      String    # A varchar type string, for short strings
     property :body,       Text      # A text block, for longer string data.
     property :created_at, DateTime  # A DateTime, for any date you might like.
  end

  class Comment < Base; belongs_to :user; end
  class User < Base; end
end

module Fireside::Controllers
  class Index
    def get
      @posts = Post.find :all
      render :index
    end
  end
end

module Fireside::Views
  def layout
    html do
      head { title "Fireside" }
      body do
        h1 "Fireside - A MicroReddit in the Ureter of Alex"
        self << yield
      end
    end
  end

  def index
    @posts.each do |post|
      h1 post.title
    end
  end
end
