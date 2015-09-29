From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:44 -0400
Subject: [lustre-devel] [PATCH 01/29] staging/lustre: Remove unused
	target_print_req()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This is a server-side request printing function, so we don't
really need it on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Reported-by: Arnd Bergmann <arnd@arndb.de>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  4 ---
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 30 ----------------------
 2 files changed, 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 5262b4f..22f3777 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -720,10 +720,6 @@ ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
 
 extern const struct sysfs_ops lustre_sysfs_ops;
 
-/* lproc_ptlrpc.c */
-struct ptlrpc_request;
-void target_print_req(void *seq_file, struct ptlrpc_request *req);
-
 /* all quota proc functions */
 int lprocfs_quota_rd_bunit(char *page, char **start,
 			   loff_t off, int count,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index d66a7b8..3a212b4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -890,36 +890,6 @@ ptlrpc_lprocfs_svc_req_history_next(struct seq_file *s,
 	return NULL;
 }
 
-/* common ost/mdt so_req_printer */
-void target_print_req(void *seq_file, struct ptlrpc_request *req)
-{
-	/* Called holding srv_lock with irqs disabled.
-	 * Print specific req contents and a newline.
-	 * CAVEAT EMPTOR: check request message length before printing!!!
-	 * You might have received any old crap so you must be just as
-	 * careful here as the service's request parser!!! */
-	struct seq_file *sf = seq_file;
-
-	switch (req->rq_phase) {
-	case RQ_PHASE_NEW:
-		/* still awaiting a service thread's attention, or rejected
-		 * because the generic request message didn't unpack */
-		seq_printf(sf, "<not swabbed>\n");
-		break;
-	case RQ_PHASE_INTERPRET:
-		/* being handled, so basic msg swabbed, and opc is valid
-		 * but racing with mds_handle() */
-	case RQ_PHASE_COMPLETE:
-		/* been handled by mds_handle() reply state possibly still
-		 * volatile */
-		seq_printf(sf, "opc %d\n", lustre_msg_get_opc(req->rq_reqmsg));
-		break;
-	default:
-		DEBUG_REQ(D_ERROR, req, "bad phase %d", req->rq_phase);
-	}
-}
-EXPORT_SYMBOL(target_print_req);
-
 static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 {
 	struct ptlrpc_service *svc = s->private;
-- 
2.1.0
