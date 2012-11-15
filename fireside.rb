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

     property :id,         Serial
     property :title,      String
     property :body,       Text
     property :created_at, DateTime
     property :upvotes,    Integer
     property :downvotes,  Integer
  end

  class Comment
    include DataMapper::Resource

    property :id,         Serial
    property :url,        String
    property :body,       Text
  end
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
      head { title "My Blog" }
      body do
        h1 "My Blog"
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
