From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 27 Oct 2010 21:06:32 +0800
Subject: [Lustre-devel] changelog for whole filesystem?
Message-ID: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I had an interesting idea today during a discussion on HSM.  One of the issues with enabling HSM today is that a full-filesystem scan must be done initially to populate the policy engine database.

I was thinking that it would be useful to have a virtual changelog that provides a feed from internally traversing the whole filesystem in an efficient manner.  For bug 22741 we have implemented a virtual index in the OSD which will return all of the in-use ldiskfs inodes in inode-number order (which is the fastest way to read/stat all of the inodes).  It probably wouldn't be too hard to hook this OSD callback into the changelog API, so that reading a special changelog file would return all of the files in the filesystem.  It is possible to generate the full pathnames of these inodes via the "link" xattr, if that is needed.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
