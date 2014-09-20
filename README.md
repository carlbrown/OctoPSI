# OctoPSI

## Octopress Socket Interface

I really love [OctoPress](http://octopress.org), and I've been using it [for more than a year now](http://www.escortmissions.com/blog/2013/07/08/moving-to-octopress.html).  I love the performance, and I **REALLY** love the security.  I use it for several different blogs.

But I've noticed that I don't blog as much as I used to.  

My blogging rate slowed way down when [SquareSpace removed their XMLRPC interface](http://www.red-sweater.com/blog/2809/state-of-the-squarespace) in favor of [their crappy app](http://geeksjourney.com/why-squarespace-sucks-and-will-never-be-a-wordpress-killer).  Octopress is great, and **much** better than SquareSpace, but it's still not as convenient as Wordpress (or SquareSpace before they killed XMLRPC).

I miss the ability to blog quickly and easily, and I miss my tools.  I especially miss [MarsEdit](http://www.red-sweater.com/marsedit/).  And I miss being able to create a post or a draft from my iPhone or iPad.

So I decided to write an XMLRPC bridge for OctoPress, which I've now done.  It's still early -- I'm starting to use it regularly to test it.  It's only just gotten reliable enough that I trust it (and even then, only because I can get everything back with git if I need to).  I wouldn't recommended it for people who aren't Ruby-savvy and early adopters, but watch this space, and hopefully I'll feel more comfortable about other people using it soon.

== Using OctoPSI

You have to run the `bin/OctoPSI` script with the argument of the parent directory to your OctoPress directories.  It will bind to localhost port 4004 (you can override the port on the command line, but not localhost for security reasons).  Then you have to connect to `http://localhost:4004/xmlrpc.php` with your blogging tool, either by running your tool (e.g. the [MarsEdit Mac app](http://www.red-sweater.com/marsedit/)) directly on the same host as your OctoPress source, or using something like an SSH tunnel to forward that port securely to the host where you are running your tool.  Use the "Moveable Type" API setting, and use the name of your blog directory as the blogID.

Then you'll need to run `bin/run_rake_from_cron.sh` periodically from cron.  It will check for changes and, if it finds any, it will generate and deploy your blog.

(If any of that doesn't make sense, hang on, and I'll have better instructions later once there has been more testing and I'm more comfortable about non-geeks using it.)

== TODO

* Username/Password authentication 
* SSL support (or at least instructions on how to set up an SSL proxy)
* Organize and comment the code
* Lots of testing
* Whatever else I'm forgetting

== Contributing to OctoPSI
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2014 Carl Brown. 
Distributed under the MIT license.
See the file LICENSE for further details.

