From: Eric Barton <eeb@sun.com>
Date: Tue, 11 Nov 2008 22:11:41 +0000
Subject: [Lustre-devel] Filesystem as a Database?
In-Reply-To: <492897526.2298751226422985006.JavaMail.root@dahlback.prod.local>
References: <492897526.2298751226422985006.JavaMail.root@dahlback.prod.local>
Message-ID: <56299F5AA95349789A097677617D95B7@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Daire,

> I'm curious if there is any interest in building a more DB-like
> interface into Lustre so that fast queries can be performed on the
> filesystem and things like file versioning could be recorded. We
> currently use an inhouse digital asset DB (DAB) which essentially
> uses a SQL database to version latest "releases" of files and record
> dependencies between files stored on the filesystem. Is the upcoming
> "Changelogs" feature a basic DB of sorts already?

Not in itself - but the changelog could be used as a feed for a database
that tracks the filesystem, and then you could run your general purpose
queries there.

> Our current asset DB uses special hidden dirs on the filesystem to
> "store" all the files and a separate SQL DB is used to record all
> their asset metadata and relationships - it might be nice one day to
> only need the filesystem. No doubt this is somewhat outside Lustre's
> mission statement but I thought I'd mention it! If nothing else it
> might be nice to be able to record simple metadata in files
> (e.g. EAs) and be able to search the filesystem quickly for files
> with certain attributes. And if OSSs could simultaneously search
> their own OSTs/DBs then it would be pretty scalable.

Indeed.  To keep with the design ideal of eliminating all scanning in
normal operation, fast querying like this relies on being able to build
and maintain an index on arbitrary file properties.  This is quite an
interesting challenge if it is not to interfere with regular filesystem
performance and makes at least the metadata server look much more like a
general purpose database than a posix namespace.  So in that respect it
does fall outside our current mission statement.  But as filesystems
scale up to trillions of files, even fully parallel scans of the namespace
will start to take unacceptably long and something like this could begin
to become a requirement.

    Cheers,
              Eric
