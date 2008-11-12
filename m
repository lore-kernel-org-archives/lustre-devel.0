From: Daire Byrne <Daire.Byrne@framestore.com>
Date: Wed, 12 Nov 2008 09:55:51 +0000 (GMT)
Subject: [Lustre-devel] Filesystem as a Database?
In-Reply-To: <1226442253.20254.14.camel@pc.interlinx.bc.ca>
Message-ID: <676021711.2342261226483751092.JavaMail.root@dahlback.prod.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric/Brian,

Cheers for the replies. I was really just thinking out loud while trying to get my head around the design of our new inhouse asset database. I was imagining what useful functionality there could be in mixing a filesystem and database together. Sorry for spamming the devel list!

Daire

----- "Brian J. Murrell" <Brian.Murrell@Sun.COM> wrote:

> On Tue, 2008-11-11 at 22:11 +0000, Eric Barton wrote:
> > 
> > Not in itself - but the changelog could be used as a feed for a
> database
> > that tracks the filesystem, and then you could run your general
> purpose
> > queries there.
> ...
> > Indeed.  To keep with the design ideal of eliminating all scanning
> in
> > normal operation, fast querying like this relies on being able to
> build
> > and maintain an index on arbitrary file properties.  This is quite
> an
> > interesting challenge if it is not to interfere with regular
> filesystem
> > performance and makes at least the metadata server look much more
> like a
> > general purpose database than a posix namespace.  So in that respect
> it
> > does fall outside our current mission statement.  But as
> filesystems
> > scale up to trillions of files, even fully parallel scans of the
> namespace
> > will start to take unacceptably long and something like this could
> begin
> > to become a requirement.
> 
> Just as a datapoint, not really a suggest to use either of them, but
> this sounds an awful lot like what beagle and tracker aim to do for
> smaller scale filesystems today.  Granted those two indexers are more
> interested in content (i.e. indexing what's in files) than metadata
> (which is what I'm, perhaps incorrectly, understanding you are more
> interested in indexing) but there is nothing stopping anyone from
> adding
> a backend to track file metadata and query it-- if anyone was
> interested
> in it.  In fact beagle at least does index some metadata like file
> names, extensions, file/mime-type, etc.
> 
> What is interesting is that in correlation or perhaps contrast to our
> changelogs, beagle (and probably tracker) use the Linux inotify
> interface to find out when filesystem state has changed.
> 
> b.
