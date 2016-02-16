From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:04 -0500
Subject: [lustre-devel] [PATCH 32/45] staging/lustre/libcfs: Remove stray
	spaces after function name
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-33-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Problem highlighted by checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c | 2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c         | 2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.h         | 3 +--
 drivers/staging/lustre/lustre/libcfs/workitem.c          | 9 ++++-----
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
index 04203b3..3f3c2d9 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c
@@ -142,7 +142,7 @@ void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *msgdata)
 	argv[4] = buf;
 	argv[5] = NULL;
 
-	libcfs_run_upcall (argv);
+	libcfs_run_upcall(argv);
 }
 EXPORT_SYMBOL(libcfs_run_lbug_upcall);
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 967f8d7..d9bb2b5 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -378,7 +378,7 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	__LASSERT(debug_buf == string_buf);
 
 	tage->used += needed;
-	__LASSERT (tage->used <= PAGE_CACHE_SIZE);
+	__LASSERT(tage->used <= PAGE_CACHE_SIZE);
 
 console:
 	if ((mask & libcfs_printk) == 0) {
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 92a00ed..2285744 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -279,8 +279,7 @@ cfs_trace_get_tcd(void)
 	return tcd;
 }
 
-static inline void
-cfs_trace_put_tcd (struct cfs_trace_cpu_data *tcd)
+static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
 {
 	cfs_trace_unlock_tcd(tcd, 0);
 
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 24400df..9d80cfb 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -163,7 +163,7 @@ cfs_wi_deschedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 		wi->wi_scheduled = 0;
 	}
 
-	LASSERT (list_empty(&wi->wi_list));
+	LASSERT(list_empty(&wi->wi_list));
 
 	spin_unlock(&sched->ws_lock);
 	return rc;
@@ -186,7 +186,7 @@ cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 	spin_lock(&sched->ws_lock);
 
 	if (!wi->wi_scheduled) {
-		LASSERT (list_empty(&wi->wi_list));
+		LASSERT(list_empty(&wi->wi_list));
 
 		wi->wi_scheduled = 1;
 		sched->ws_nscheduled++;
@@ -198,14 +198,13 @@ cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 		}
 	}
 
-	LASSERT (!list_empty(&wi->wi_list));
+	LASSERT(!list_empty(&wi->wi_list));
 	spin_unlock(&sched->ws_lock);
 	return;
 }
 EXPORT_SYMBOL(cfs_wi_schedule);
 
-static int
-cfs_wi_scheduler (void *arg)
+static int cfs_wi_scheduler(void *arg)
 {
 	struct cfs_wi_sched	*sched = (struct cfs_wi_sched *)arg;
 
-- 
2.1.0
