require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migration'
require 'camping'

Camping.goes :Fireside

module Fireside::Models
  class Post < Base; belongs_to :user; end
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
