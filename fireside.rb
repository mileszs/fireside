require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
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
>>>>>>> 6ddf1b3bd9bc592030a0180375f727e55ba6fa18
