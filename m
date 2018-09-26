From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:48:12 -0400
Subject: [lustre-devel] [PATCH 20/25] lustre: lnet: handle empty CPTs
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Make the LND code handle empty CPTs.

If a scheduler is associated with an empty CPT it will have no
threads created. If a NID hashes to that CPT, then pick the
next scheduler which does have at least 1 started thread.
Associate the connection with the CPT of the selected scheduler

Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9448
Reviewed-on: https://review.whamcloud.com/27145
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 42 ++++++++++++++++++++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 25 ++++++++++++-
 2 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 9e8248e..0ce9962 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -622,6 +622,36 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 	return 1;
 }
 
+/*
+ * Get the scheduler bound to this CPT. If the scheduler has no
+ * threads, which means that the CPT has no CPUs, then grab the
+ * next scheduler that we can use.
+ *
+ * This case would be triggered if a NUMA node is configured with
+ * no associated CPUs.
+ */
+static struct kib_sched_info *kiblnd_get_scheduler(int cpt)
+{
+	struct kib_sched_info *sched;
+	int i;
+
+	sched = kiblnd_data.kib_scheds[cpt];
+
+	if (sched->ibs_nthreads > 0)
+		return sched;
+
+	cfs_percpt_for_each(sched, i, kiblnd_data.kib_scheds) {
+		if (sched->ibs_nthreads > 0) {
+			CDEBUG(D_NET,
+			       "scheduler[%d] has no threads. selected scheduler[%d]\n",
+			       cpt, sched->ibs_cpt);
+			return sched;
+		}
+	}
+
+	return NULL;
+}
+
 struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 				    struct rdma_cm_id *cmid,
 				    int state, int version)
@@ -656,9 +686,17 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	dev = net->ibn_dev;
 
 	cpt = lnet_cpt_of_nid(peer_ni->ibp_nid, peer_ni->ibp_ni);
-	sched = kiblnd_data.kib_scheds[cpt];
+	sched = kiblnd_get_scheduler(cpt);
+	if (!sched) {
+		CERROR("no schedulers available. node is unhealthy\n");
+		goto failed_0;
+	}
 
-	LASSERT(sched->ibs_nthreads > 0);
+	/*
+	 * The cpt might have changed if we ended up selecting a non cpt
+	 * native scheduler. So use the scheduler's cpt instead.
+	 */
+	cpt = sched->ibs_cpt;
 
 	init_qp_attr = kzalloc_cpt(sizeof(*init_qp_attr), GFP_NOFS, cpt);
 	if (!init_qp_attr) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ad94837..1a49f5e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -652,8 +652,19 @@ struct ksock_peer *
 	struct ksock_sched *sched;
 	int i;
 
-	LASSERT(info->ksi_nthreads > 0);
+	if (info->ksi_nthreads == 0) {
+		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
+			if (info->ksi_nthreads > 0) {
+				CDEBUG(D_NET,
+				       "scheduler[%d] has no threads. selected scheduler[%d]\n",
+				       cpt, info->ksi_cpt);
+				goto select_sched;
+			}
+		}
+		return NULL;
+	}
 
+select_sched:
 	sched = &info->ksi_scheds[0];
 	/*
 	 * NB: it's safe so far, but info->ksi_nthreads could be changed
@@ -1255,6 +1266,15 @@ struct ksock_peer *
 	peer_ni->ksnp_error = 0;
 
 	sched = ksocknal_choose_scheduler_locked(cpt);
+	if (!sched) {
+		CERROR("no schedulers available. node is unhealthy\n");
+		goto failed_2;
+	}
+	/*
+	 * The cpt might have changed if we ended up selecting a non cpt
+	 * native scheduler. So use the scheduler's cpt instead.
+	 */
+	cpt = sched->kss_info->ksi_cpt;
 	sched->kss_nconns++;
 	conn->ksnc_scheduler = sched;
 
@@ -2402,6 +2422,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		info->ksi_nthreads_max = nthrs;
 		info->ksi_cpt = i;
 
+		if (nthrs == 0)
+			continue;
+
 		info->ksi_scheds = kzalloc_cpt(info->ksi_nthreads_max * sizeof(*sched),
 					       GFP_NOFS, i);
 		if (!info->ksi_scheds)
-- 
1.8.3.1
