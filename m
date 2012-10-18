From: Ezell, Matthew A. <ezellma@ornl.gov>
Date: Thu, 18 Oct 2012 11:07:24 -0400
Subject: [Lustre-devel] Hard Links in e2scan
Message-ID: <CCA5936C.134D5%ezellma@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello-

We are using e2scan to do a full metadata scan, which we then use to
generate lists of files eligible for purging.  We recently found a bunch
of files that should have been purged, but were not.  Looking closer,
these files had large link counts; our users have many hard links to the
same inode.  e2scan is only reporting the first instance of the hard link,
so our purge process only removes a single hard link to a given inode per
run (actually, reducing the link count changes the ctime, so it's multiple
days before another hard link is eligible to be removed).

Looking at the source for e2scan, the report_file_name() function calls
ext2fs_fast_unmark_inode_bitmap2() to mark that this inode has been
processed.  Then when filelist_dblist_iterate_cb() gets called for the
"other" paths that correspond to that inode, it checks
is_file_interesting() which calls ext2fs_fast_test_inode_bitmap2().  The
inode is no longer set in the bitmap, so the path isn't reported.

I'm not very familiar with this code, so I would appreciate some advice
from the experts.  Is it "safe" to remove the
ext2fs_fast_unmark_inode_bitmap2() call from report_file_name() because we
want the same inode reported multiple times if it has multiple links?  Are
there situations where this could be the wrong thing to do, or is there a
better way to handle this?

Thanks in advance,
~Matt

---
Matt Ezell
HPC Systems Administrator
Oak Ridge National Laboratory
