sitemap-generator
=================

**Usage:** sitemap-generator.sh [OPTIONS] url

**Options:**
-    -o,  --output       Define output filename. Default: sitemap.xml
-    -d,  --domains      Restrict the crawling to this specific comma separated domains list
-    -l,  --level        Specify recursion maximum depth level depth. Default 5.
-    -t,  --timeout      Set the network timeout in seconds.
-    -r,  --reject       Rejected comma separated list of file name suffixes or patterns.  Default: .jpg,.jpeg,.css,.js,.ico,.png,.gif,.swf
-    -x,  --reject-regex Rejected regular expression of complete URL.  -    --max-redirect      Specifies the maximum number of redirections to follow: Default 20
-    -f,  --frequency    Define URLs frequency. Default: monthly See: http://www.sitemaps.org/protocol.html#changefreqdef
-    -p,  --priority     Define the priority for all urls. Default 0.8 See: http://www.sitemaps.org/protocol.html#prioritydef
-    -h,  --help         See this help
