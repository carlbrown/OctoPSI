require "#{File.dirname(__FILE__)}/blog"
require "#{File.dirname(__FILE__)}/post"

module OctoPSI
  class OctoPSI

    def initialize(blog_parent_dir)
      @source_dir = blog_parent_dir
      @blogs={}
      Dir.foreach(blog_parent_dir) do |entry|
        next if entry == '.' or entry == '..'
        next unless File.directory?(File.join(blog_parent_dir, entry))
        potential_blog_dir = File.join(File.join(blog_parent_dir, entry),'source')
        next unless File.exists?(potential_blog_dir)
        next unless File.directory?(potential_blog_dir)
        next unless File.exists?(File.join(potential_blog_dir, '_posts'))
        next unless File.directory?(File.join(potential_blog_dir, '_posts'))
        new_blog=Blog.new(potential_blog_dir)
        if new_blog
          @blogs[new_blog.name] = new_blog
        end
      end

    end

    def blogs
      @blogs
    end

    def getRecentPosts(blogId, user, password, limit)
      blog = @blogs[blogId]
      response = blog.get_recent_posts_response(limit)
    end

    def getPost(postId, username, password, ignored_options = {})
      (blog_name, post_name) = postId.split('/',2)
      blog = @blogs[blog_name]
      post = blog.get_post_by_name(post_name)
      post.web_response
    end

    def supportedTextFilters()
      [
          { 'key' => 'markdown', 'label' => 'Markdown' },
      ]
    end

    def getCategoryList(blogId, user, pass)
      blog = @blogs[blogId]
      cats = blog.get_categories
      response = []
      cats.each {|c|
        response << {'categoryId' => c, 'categoryName' => c}
      }
      response
    end

    def getPostCategories(postId, user, pass)
      (blog_name, post_name) = postId.split('/',2)
      blog = @blogs[blog_name]
      post = blog.get_post_by_name(post_name)
      cats = post.get_categories
      response = []
      cats.each {|c|
        response << {'categoryId' => c, 'categoryName' => c}
      }
      response
    end

    def setPostCategories(postId, user, pass, categories)
      (blog_name, post_name) = postId.split('/',2)
      blog = @blogs[blog_name]
      post = blog.get_post_by_name(post_name)
      post.replace_categories(categories)
    end

    def editPost(postId, username, password, content, publish)
      (blog_name, post_name) = postId.split('/',2)
      blog = @blogs[blog_name]
      post = blog.get_post_by_name(post_name)
      saved = post.edit_content(content, publish)
      if saved
        blog.load_post_names
        blog.load_posts
      end
      saved
    end

    def newPost(blogId, username, password, content, publish)
      blog = @blogs[blogId]
      new_filename = blog.create_post(content, publish)
    end

    def newMediaObject(blogId, username, password, data)
      blog = @blogs[blogId]
      new_image_path = blog.newMediaObject(data)

      { 'url' => new_image_path }
    end

    def deletePost(apikey, postId, user, pass, publish)
      false #not supported at the moment, for safety. Make it a draft instead
    end

  end
end