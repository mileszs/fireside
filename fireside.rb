require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'camping'
require './inactive_support'
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

    EPOCH = Time.local(20011, 12, 8, 7, 46, 43).to_time

    def epoch_seconds
      (created_at.strftime("%s").to_i - EPOCH.to_i).to_f
    end

    def score
      self.upvotes.to_i - self.downvotes.to_i
    end

    def hot
      displacement = Math.log( [score.abs, 1].max,  10 )

      sign = if displacement > 0
        1
      elsif displacement < 0
        -1
      else
        0
      end

      (displacement * sign.to_f) + (epoch_seconds / 45000 )
    end
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

      # probably should do this in db... meh
      case @request[:sort]
      when 'hot'
        @posts.sort! { |a,b| b.hot <=> a.hot }
      when 'score'
        @posts.sort! { |a,b| b.score <=> a.score }
      end

      render :index
    end
  end


  class ShowN
    def get(post_id)
      @post = Post.get(post_id)
      if @post != nil
        render :show
      else
        redirect Index
      end
    end
  end

  class New
    def get
      @post = Post.new
      render :new
    end
  end

  class Create
    def post
      @post = Post.create(:title => @input.title,
                          :url        => @input.url,
                          :created_at => Time.now)
      redirect Index
    end
  end

  class UpvoteN
    def get(post_id)
      @post = Post.get(post_id)
      if @post != nil
        @post.upvotes = @post.upvotes.to_i + 1
        @post.save
      end
      redirect Index
    end
  end

  class DownvoteN
    def get(post_id)
      @post = Post.get(post_id)
      if @post != nil
        @post.downvotes = @post.downvotes.to_i + 1
        @post.save

      end
      redirect Index
    end
  end

  class CommentsN
    def post(post_id)
      @post = Post.get(post_id)
      if @post != nil
        @post.comments.create(:body => @input.content)
        redirect ShowN, @post.id
      else
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
        a 'Add a Post', :href => R(New)
      end
    end
  end

  def index
    p do
      span "Sort by: "
      a 'Most Recent', :href => "#{R(Index)}"
      span " | "
      a 'Hottest', :href => "#{R(Index)}?sort=hot"
      span " | "
      a 'Highest Score', :href => "#{R(Index)}?sort=score"
    end
    table do
      thead do
        tr do
          th 'Title'
          th 'Created At'
          th 'Upvotes'
          th 'Downvotes'
          th "Comments"
        end
      end
      tbody do
        @posts.each do |post|
          tr do
            td do
              a post.title, :href => post.url, :target => '_blank'
            end


            td post.created_at.strftime "%D %r"
            td do
              a "#{post.upvotes} UP", :href => R(UpvoteN, post.id)
            end
            td do
              a "#{post.downvotes} DOWN", :href => R(DownvoteN, post.id)
            end
            th do
              a "Comments (#{post.comments.length})", :href => R(ShowN,post.id)
            end
          end
        end
      end
    end
  end

  def show
    h2 @post.title

    h3 "Comments"
    a "Back", :href => R(Index)
    ul do
      @post.comments.each do |comment|
        li comment.body
      end
    end

    form :action => R(CommentsN,@post.id), :method => 'post' do
      textarea :name => 'content'


      input :type => 'submit', :class => 'submit', :value => 'Add Comment'
    end

  end

  def new
    h2 'Add a Post'
    form :action => R(Create), :method => 'post' do
      label 'Title', :for => 'title'
      input :name => 'title', :type => 'text'

      label 'URL', :for => 'url'
      input :name => 'url', :id => 'url', :type => 'text'

      input :type => 'submit', :class => 'submit', :value => 'New'
    end
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
