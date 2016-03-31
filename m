From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:38 -0400
Subject: [lustre-devel] [PATCH 4/6] staging: lustre: libcfs: remove MMSPACE
	macros
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Another abstraction that is not needed.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13841
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |    5 -----
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   17 ++++++++---------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index 12fde3c..c4b4284 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -65,9 +65,4 @@
 #define NUM_CACHEPAGES totalram_pages
 #endif
 
-#define DECL_MMSPACE		mm_segment_t __oldfs
-#define MMSPACE_OPEN \
-	do { __oldfs = get_fs(); set_fs(get_ds()); } while (0)
-#define MMSPACE_CLOSE	       set_fs(__oldfs)
-
 #endif /* __LINUX_CFS_MEM_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index ec3bc04..5169597 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -707,10 +707,9 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	struct cfs_trace_page	*tage;
 	struct cfs_trace_page	*tmp;
 	char			*buf;
+	mm_segment_t __oldfs;
 	int rc;
 
-	DECL_MMSPACE;
-
 	cfs_tracefile_write_lock();
 
 	filp = filp_open(filename, O_CREAT | O_EXCL | O_WRONLY | O_LARGEFILE,
@@ -729,11 +728,12 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		rc = 0;
 		goto close;
 	}
+	__oldfs = get_fs();
+	set_fs(get_ds());
 
 	/* ok, for now, just write the pages.  in the future we'll be building
 	 * iobufs with the pages and calling generic_direct_IO
 	 */
-	MMSPACE_OPEN;
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
 		__LASSERT_TAGE_INVARIANT(tage);
 
@@ -752,7 +752,7 @@ int cfs_tracefile_dump_all_pages(char *filename)
 		list_del(&tage->linkage);
 		cfs_tage_free(tage);
 	}
-	MMSPACE_CLOSE;
+	set_fs(__oldfs);
 	rc = vfs_fsync(filp, 1);
 	if (rc)
 		pr_err("sync returns %d\n", rc);
@@ -986,13 +986,12 @@ static int tracefiled(void *arg)
 	struct tracefiled_ctl *tctl = arg;
 	struct cfs_trace_page *tage;
 	struct cfs_trace_page *tmp;
+	mm_segment_t __oldfs;
 	struct file *filp;
 	char *buf;
 	int last_loop = 0;
 	int rc;
 
-	DECL_MMSPACE;
-
 	/* we're started late enough that we pick up init's fs context */
 	/* this is so broken in uml?  what on earth is going on? */
 
@@ -1025,8 +1024,8 @@ static int tracefiled(void *arg)
 			__LASSERT(list_empty(&pc.pc_pages));
 			goto end_loop;
 		}
-
-		MMSPACE_OPEN;
+		__oldfs = get_fs();
+		set_fs(get_ds());
 
 		list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
 			static loff_t f_pos;
@@ -1051,7 +1050,7 @@ static int tracefiled(void *arg)
 				break;
 			}
 		}
-		MMSPACE_CLOSE;
+		set_fs(__oldfs);
 
 		filp_close(filp, NULL);
 		put_pages_on_daemon_list(&pc);
-- 
1.7.1
