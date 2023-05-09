To generate the static site, run `wget --exclude-domains blog.covidliste.com -FEmnH http://localhost:3000/`
Try it out with `ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => Dir.pwd).start'`

Hat tip to [Simon Fish](https://simon.fish/blog/static-site-building-with-rails.html) for the help