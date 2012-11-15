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

    has n, :comments

    property :id,         Serial
    property :title,      String
    property :url,        String
    property :created_at, DateTime
    property :upvotes,    Integer
    property :downvotes,  Integer
  end

  class Comment
    include DataMapper::Resource

    belongs_to :post

    property :id,         Serial
    property :body,       Text
  end

  DataMapper.auto_migrate!
end

module Fireside::Controllers
  class Index
    def get
      @posts = Post.all(:order => :created_at.desc)
      render :index
    end
  end

  class New
    def get

    end

    def post
    end
  end

  class UpvoteN
    def get(post_id)
      @post = Post.get(post_id)
      if @post

        @post.upvotes = @post.upvotes.to_i + 1
        @post.save
        redirect Index
      end
    end
  end

  class DownvoteN
    def get(post_id)
      @post = Post.get(post_id)
      if @post
        @post.downvotes = @post.downvotes.to_i + 1
        @post.save
        redirect Index
      end
    end
  end

end

module Fireside::Views
  def layout
    html do
      head { title "Fireside" }
      body do
        h1 "Fireside - A Micro-Reddit in the Ureter of Alex"
        self << yield
      end
    end
  end

  def index
      table do
        thead do
          tr do
            th 'Title'
            th 'Body'
            th 'Created At'
            th 'Upvotes'
            th 'Downvotes'
          end
        end
        tbody do
          @posts.each do |post|
            tr do
              th post.title
              th post.created_at
              th post.upvotes
              th post.downvotes
            end
          end
        end
      end
  end

  def new
  end


  def upvote
  end

  def downvote
  end

end

Fireside::Models::Post.create(
  :title      => 'My new kitty.',
  :url        => 'http://placekitten.com/800/600',
  :created_at => Time.parse('2012-01-01 19:00 UTC')
).comments.create(
  :body => 'This is so cute!!!!!!!!!'
)
