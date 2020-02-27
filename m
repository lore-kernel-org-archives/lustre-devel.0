From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:08 -0500
Subject: [lustre-devel] [PATCH 020/622] lnet: libcfs: remove unnecessary
 set_fs(KERNEL_DS)
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mike Marciniszyn <mike.marciniszyn@intel.com>

When we converted to using kernel_write(), we left some
set_fs() calls that are not unnecessary.
Remove them.

Original OpenSFS version of this patch, as mentioned below,
did the full conversion to kernel_write.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10560
lustre-commit: b9a32054600a ("LU-10560 libcfs: Use kernel_write when appropriate")
Signed-off-by: Mike Marciniszyn <mike.marciniszyn@intel.com>
Reviewed-on: https://review.whamcloud.com/31154
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
igned-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 3b29116..6e4cc31 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -807,7 +807,6 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
 	char *buf;
-	mm_segment_t __oldfs;
 	int rc;
 
 	down_write(&cfs_tracefile_sem);
@@ -828,8 +827,6 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		rc = 0;
 		goto close;
 	}
-	__oldfs = get_fs();
-	set_fs(KERNEL_DS);
 
 	/* ok, for now, just write the pages.  in the future we'll be building
 	 * iobufs with the pages and calling generic_direct_IO
@@ -851,7 +848,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		list_del(&tage->linkage);
 		cfs_tage_free(tage);
 	}
-	set_fs(__oldfs);
+
 	rc = vfs_fsync(filp, 1);
 	if (rc)
 		pr_err("sync returns %d\n", rc);
-- 
1.8.3.1
