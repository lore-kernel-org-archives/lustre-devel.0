From: Daire Byrne <Daire.Byrne@framestore.com>
Date: Tue, 11 Nov 2008 17:03:05 +0000 (GMT)
Subject: [Lustre-devel] Filesystem as a Database?
Message-ID: <492897526.2298751226422985006.JavaMail.root@dahlback.prod.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I'm curious if there is any interest in building a more DB-like interface into Lustre so that fast queries can be performed on the filesystem and things like file versioning could be recorded. We currently use an inhouse digital asset DB (DAB) which essentially uses a SQL database to version latest "releases" of files and record dependencies between files stored on the filesystem. Is the upcoming "Changelogs" feature a basic DB of sorts already?

Our current asset DB uses special hidden dirs on the filesystem to "store" all the files and a separate SQL DB is used to record all their asset metadata and relationships - it might be nice one day to only need the filesystem. No doubt this is somewhat outside Lustre's mission statement but I thought I'd mention it! If nothing else it might be nice to be able to record simple metadata in files (e.g. EAs) and be able to search the filesystem quickly for files with certain attributes. And if OSSs could simultaneously search their own OSTs/DBs then it would be pretty scalable.

Regards,

Daire
