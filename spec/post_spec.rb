require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'stringex'


describe 'Octopsi' do
  it 'returns array for get_posts with correct file count' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(dir + '/source')
      Dir.mkdir(dir + '/source/_posts')
      File.open(dir + '/_config.yml', 'w') do |file|
        file.puts 'url: http://example.com'
      end
      blog = OctoPSI::Blog.new(dir + '/source')
      1.upto(5) do |i|
        File.open(dir + "/source/_posts/testfile#{i}.markdown", 'w') do |file|
          file.puts "---\npermalink: /testpost\n---\nTest"
        end
      end
      posts = blog.get_posts(10)
      posts.count.should == 5
    end
  end
end

describe 'Octopsi' do
  it 'returns array for get_posts with correct max file count' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(dir + '/source')
      Dir.mkdir(dir + '/source/_posts')
      File.open(dir + '/_config.yml', 'w') do |file|
        file.puts 'url: http://example.com'
      end
      blog = OctoPSI::Blog.new(dir + '/source')
      1.upto(9) do |i|
        File.open(dir + "/source/_posts/testfile#{i}.markdown", 'w') do |file|
          file.puts "---\npermalink: /testpost\n---\nTest"
        end
      end
      posts = blog.get_posts(2)
      posts.count.should == 2
      posts[0].post_name.should == 'testfile9'
      posts[1].post_name.should == 'testfile8'
    end
  end
end
