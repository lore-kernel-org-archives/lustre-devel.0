From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Tue, 11 Nov 2008 17:24:13 -0500
Subject: [Lustre-devel] Filesystem as a Database?
In-Reply-To: <56299F5AA95349789A097677617D95B7@ebpc>
References: <492897526.2298751226422985006.JavaMail.root@dahlback.prod.local>
	<56299F5AA95349789A097677617D95B7@ebpc>
Message-ID: <1226442253.20254.14.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2008-11-11 at 22:11 +0000, Eric Barton wrote:
> 
> Not in itself - but the changelog could be used as a feed for a database
> that tracks the filesystem, and then you could run your general purpose
> queries there.
...
> Indeed.  To keep with the design ideal of eliminating all scanning in
> normal operation, fast querying like this relies on being able to build
> and maintain an index on arbitrary file properties.  This is quite an
> interesting challenge if it is not to interfere with regular filesystem
> performance and makes at least the metadata server look much more like a
> general purpose database than a posix namespace.  So in that respect it
> does fall outside our current mission statement.  But as filesystems
> scale up to trillions of files, even fully parallel scans of the namespace
> will start to take unacceptably long and something like this could begin
> to become a requirement.

Just as a datapoint, not really a suggest to use either of them, but
this sounds an awful lot like what beagle and tracker aim to do for
smaller scale filesystems today.  Granted those two indexers are more
interested in content (i.e. indexing what's in files) than metadata
(which is what I'm, perhaps incorrectly, understanding you are more
interested in indexing) but there is nothing stopping anyone from adding
a backend to track file metadata and query it-- if anyone was interested
in it.  In fact beagle at least does index some metadata like file
names, extensions, file/mime-type, etc.

What is interesting is that in correlation or perhaps contrast to our
changelogs, beagle (and probably tracker) use the Linux inotify
interface to find out when filesystem state has changed.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081111/978db2d5/attachment.pgp>
