From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:44 -0500
Subject: [lustre-devel] [PATCH 056/622] lustre: ptlrpc: Serialize procfs
 access to scp_hist_reqs using mutex
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

scp_hist_reqs list can be quite long thus a lot of
userland processes can waste CPU power in spinlock cycles.

Cray-bug-id: LUS-5833
WC-bug-id: https://jira.whamcloud.com/browse/LU-11004
Lustre-commit: 413a738a37d7 ("LU-11004 ptlrpc: Serialize procfs access to scp_hist_reqs using mutex")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/32307
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  | 2 ++
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 7 +++++++
 fs/lustre/ptlrpc/service.c      | 1 +
 3 files changed, 10 insertions(+)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 674803c..cf13555 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1543,6 +1543,8 @@ struct ptlrpc_service_part {
 	 * threads starting & stopping are also protected by this lock.
 	 */
 	spinlock_t			scp_lock __cfs_cacheline_aligned;
+	/* userland serialization */
+	struct mutex			scp_mutex;
 	/** total # req buffer descs allocated */
 	int				scp_nrqbds_total;
 	/** # posted request buffers for receiving */
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index e48a4e8..0efbcfc 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -869,10 +869,12 @@ struct ptlrpc_srh_iterator {
 		if (i > cpt) /* make up the lowest position for this CPT */
 			*pos = PTLRPC_REQ_CPT2POS(svc, i);
 
+		mutex_lock(&svcpt->scp_mutex);
 		spin_lock(&svcpt->scp_lock);
 		rc = ptlrpc_lprocfs_svc_req_history_seek(svcpt, srhi,
 				PTLRPC_REQ_POS2SEQ(svc, *pos));
 		spin_unlock(&svcpt->scp_lock);
+		mutex_unlock(&svcpt->scp_mutex);
 		if (rc == 0) {
 			*pos = PTLRPC_REQ_SEQ2POS(svc, srhi->srhi_seq);
 			srhi->srhi_idx = i;
@@ -914,9 +916,11 @@ struct ptlrpc_srh_iterator {
 			seq = srhi->srhi_seq + (1 << svc->srv_cpt_bits);
 		}
 
+		mutex_lock(&svcpt->scp_mutex);
 		spin_lock(&svcpt->scp_lock);
 		rc = ptlrpc_lprocfs_svc_req_history_seek(svcpt, srhi, seq);
 		spin_unlock(&svcpt->scp_lock);
+		mutex_unlock(&svcpt->scp_mutex);
 		if (rc == 0) {
 			*pos = PTLRPC_REQ_SEQ2POS(svc, srhi->srhi_seq);
 			srhi->srhi_idx = i;
@@ -940,6 +944,7 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 
 	svcpt = svc->srv_parts[srhi->srhi_idx];
 
+	mutex_lock(&svcpt->scp_mutex);
 	spin_lock(&svcpt->scp_lock);
 
 	rc = ptlrpc_lprocfs_svc_req_history_seek(svcpt, srhi, srhi->srhi_seq);
@@ -980,6 +985,8 @@ static int ptlrpc_lprocfs_svc_req_history_show(struct seq_file *s, void *iter)
 	}
 
 	spin_unlock(&svcpt->scp_lock);
+	mutex_unlock(&svcpt->scp_mutex);
+
 	return rc;
 }
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 8dae21a..cf920ae 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -471,6 +471,7 @@ static void ptlrpc_at_timer(struct timer_list *t)
 
 	/* rqbd and incoming request queue */
 	spin_lock_init(&svcpt->scp_lock);
+	mutex_init(&svcpt->scp_mutex);
 	INIT_LIST_HEAD(&svcpt->scp_rqbd_idle);
 	INIT_LIST_HEAD(&svcpt->scp_rqbd_posted);
 	INIT_LIST_HEAD(&svcpt->scp_req_incoming);
-- 
1.8.3.1
