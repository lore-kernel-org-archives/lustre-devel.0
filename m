From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:04 -0400
Subject: [lustre-devel] [PATCH 105/151] lustre: ptlrpc: allow to limit
 number of service's rqbds
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-106-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

This patch provides a way to limit the number of rqbds per
service.
This should help to avoid OOM during heavy clients
requests load, like during target failover/recovery for
thousands of Clients.
This change has been required, even after first patch for
LU-9372 (ptlrpc: drain "ptlrpc_request_buffer_desc" objects)
which already allowed to drain unused rqbds previously
allocated during heavy load, but was not efficient during
too long period of load.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9372
Lustre-commit: d9e57a765e73 ("LU-9372 ptlrpc: allow to limit number of service's rqbds")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/29064
WC-bug-id: https://jira.whamcloud.com/browse/LU-10603
Lustre-commit: 3542f9780bf4 ("LU-10603 ptlrpc: export req_buffers_max via procfs")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31162
WC-bug-id: https://jira.whamcloud.com/browse/LU-10803
Lustre-commit: c11c61a82d66 ("LU-10803 ptlrpc: fix req_buffers_max and req_history_max setting")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/31622
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  |  2 ++
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 52 ++++++++++++++++++++++++++++++++++++++---
 fs/lustre/ptlrpc/service.c      | 14 ++++++++---
 3 files changed, 62 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index baa1eb8..22c9668 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1482,6 +1482,8 @@ struct ptlrpc_service {
 	/** under unregister_service */
 	unsigned			srv_is_stopping:1;
 
+	/** max # request buffers */
+	int				srv_nrqbds_max;
 	/** max # request buffers in history per partition */
 	int				srv_hist_nrqbds_cpt_max;
 	/** number of CPTs this service bound on */
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 163ee54..2239680 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -298,10 +298,16 @@ static const char *ll_eopcode2str(u32 opcode)
 
 	/* This sanity check is more of an insanity check; we can still
 	 * hose a kernel by allowing the request history to grow too
-	 * far.
+	 * far. The roundup to the next power of two is an empirical way
+	 * to take care that request buffer is allocated in Slab and thus
+	 * will be upgraded.
 	 */
-	bufpages = (svc->srv_buf_size + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (val > totalram_pages() / (2 * bufpages))
+	bufpages = (roundup_pow_of_two(svc->srv_buf_size) + PAGE_SIZE - 1) >>
+		   PAGE_SHIFT;
+	/* do not allow history to consume more than half max number of rqbds */
+	if ((svc->srv_nrqbds_max == 0 &&
+	     val > totalram_pages() / (2 * bufpages)) ||
+	    (svc->srv_nrqbds_max != 0 && val > svc->srv_nrqbds_max / 2))
 		return -ERANGE;
 
 	spin_lock(&svc->srv_lock);
@@ -318,6 +324,43 @@ static const char *ll_eopcode2str(u32 opcode)
 
 LPROC_SEQ_FOPS(ptlrpc_lprocfs_req_history_max);
 
+static int
+ptlrpc_lprocfs_req_buffers_max_seq_show(struct seq_file *m, void *n)
+{
+	struct ptlrpc_service *svc = m->private;
+
+	seq_printf(m, "%d\n", svc->srv_nrqbds_max);
+	return 0;
+}
+
+static ssize_t
+ptlrpc_lprocfs_req_buffers_max_seq_write(struct file *file,
+					 const char __user *buffer,
+					 size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct ptlrpc_service *svc = m->private;
+	int val;
+	int rc;
+
+	rc = kstrtoint_from_user(buffer, count, 0, &val);
+	if (rc < 0)
+		return rc;
+
+	if (val < svc->srv_nbuf_per_group && val != 0)
+		return -ERANGE;
+
+	spin_lock(&svc->srv_lock);
+
+	svc->srv_nrqbds_max = (uint)val;
+
+	spin_unlock(&svc->srv_lock);
+
+	return count;
+}
+
+LPROC_SEQ_FOPS(ptlrpc_lprocfs_req_buffers_max);
+
 static ssize_t threads_min_show(struct kobject *kobj, struct attribute *attr,
 				char *buf)
 {
@@ -1090,6 +1133,9 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 		{ .name		= "nrs_policies",
 		  .fops		= &ptlrpc_lprocfs_nrs_fops,
 		  .data		= svc },
+		{ .name		= "req_buffers_max",
+		  .fops		= &ptlrpc_lprocfs_req_buffers_max_fops,
+		  .data		= svc },
 		{ NULL }
 	};
 	static const struct file_operations req_history_fops = {
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 90c7529..57c5e28 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -148,7 +148,10 @@
 		/* NB: another thread might have recycled enough rqbds, we
 		 * need to make sure it wouldn't over-allocate, see LU-1212.
 		 */
-		if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group)
+		if (test_req_buffer_pressure ||
+		    svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group ||
+		    (svc->srv_nrqbds_max != 0 &&
+		     svcpt->scp_nrqbds_total > svc->srv_nrqbds_max))
 			break;
 
 		rqbd = ptlrpc_alloc_rqbd(svcpt);
@@ -622,6 +625,9 @@ struct ptlrpc_service *
 	/* buffer configuration */
 	service->srv_nbuf_per_group = test_req_buffer_pressure ?
 					  1 : conf->psc_buf.bc_nbufs;
+	/* do not limit max number of rqbds by default */
+	service->srv_nrqbds_max = 0;
+
 	service->srv_max_req_size = conf->psc_buf.bc_req_max_size +
 					  SPTLRPC_MAX_PAYLOAD;
 	service->srv_buf_size = conf->psc_buf.bc_buf_size;
@@ -807,8 +813,10 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			 */
 			LASSERT(atomic_read(&rqbd->rqbd_req.rq_refcount) ==
 				0);
-			if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group &&
-			    !test_req_buffer_pressure) {
+			if (svcpt->scp_nrqbds_posted >= svc->srv_nbuf_per_group ||
+			    (svc->srv_nrqbds_max != 0 &&
+			     svcpt->scp_nrqbds_total > svc->srv_nrqbds_max) ||
+			    test_req_buffer_pressure) {
 				/* like in ptlrpc_free_rqbd() */
 				svcpt->scp_nrqbds_total--;
 				kvfree(rqbd->rqbd_buffer);
-- 
1.8.3.1
