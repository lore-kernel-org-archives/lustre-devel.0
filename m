From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:59 -0500
Subject: [lustre-devel] [PATCH 191/622] lnet: socklnd: improve scheduling
 algorithm
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-192-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Modified the scheduling algorithm to use all scheduler threads
available. Previously a connection is assigned a single thread
and can only use that one. With this patch any scheduler thread
available on the assigned CPT can pick up and work on requests
queued on the connection.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11415
Lustre-commit: 89df5e712ffd ("LU-11415 socklnd: improve scheduling algorithm")
Reviewed-on: https://review.whamcloud.com/33740
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 156 +++++++++++++-----------------------
 net/lnet/klnds/socklnd/socklnd.h    |  18 ++---
 net/lnet/klnds/socklnd/socklnd_cb.c |   8 +-
 3 files changed, 65 insertions(+), 117 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index ba5623a..8b283ac 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -648,34 +648,21 @@ struct ksock_peer *
 static struct ksock_sched *
 ksocknal_choose_scheduler_locked(unsigned int cpt)
 {
-	struct ksock_sched_info	*info = ksocknal_data.ksnd_sched_info[cpt];
-	struct ksock_sched *sched;
+	struct ksock_sched *sched = ksocknal_data.ksnd_schedulers[cpt];
 	int i;
 
-	if (info->ksi_nthreads == 0) {
-		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
-			if (info->ksi_nthreads > 0) {
+	if (sched->kss_nthreads == 0) {
+		cfs_percpt_for_each(sched, i, ksocknal_data.ksnd_schedulers) {
+			if (sched->kss_nthreads > 0) {
 				CDEBUG(D_NET,
 				       "scheduler[%d] has no threads. selected scheduler[%d]\n",
-				       cpt, info->ksi_cpt);
-				goto select_sched;
+				       cpt, sched->kss_cpt);
+				return sched;
 			}
 		}
 		return NULL;
 	}
 
-select_sched:
-	sched = &info->ksi_scheds[0];
-	/*
-	 * NB: it's safe so far, but info->ksi_nthreads could be changed
-	 * at runtime when we have dynamic LNet configuration, then we
-	 * need to take care of this.
-	 */
-	for (i = 1; i < info->ksi_nthreads; i++) {
-		if (sched->kss_nconns > info->ksi_scheds[i].kss_nconns)
-			sched = &info->ksi_scheds[i];
-	}
-
 	return sched;
 }
 
@@ -1276,7 +1263,7 @@ struct ksock_peer *
 	 * The cpt might have changed if we ended up selecting a non cpt
 	 * native scheduler. So use the scheduler's cpt instead.
 	 */
-	cpt = sched->kss_info->ksi_cpt;
+	cpt = sched->kss_cpt;
 	sched->kss_nconns++;
 	conn->ksnc_scheduler = sched;
 
@@ -1316,11 +1303,11 @@ struct ksock_peer *
 	 *    (b) normal I/O on the conn is blocked until I setup and call the
 	 *	socket callbacks.
 	 */
-	CDEBUG(D_NET, "New conn %s p %d.x %pI4h -> %pI4h/%d incarnation:%lld sched[%d:%d]\n",
+	CDEBUG(D_NET,
+	       "New conn %s p %d.x %pI4h -> %pI4h/%d incarnation:%lld sched[%d]\n",
 	       libcfs_id2str(peerid), conn->ksnc_proto->pro_version,
 	       &conn->ksnc_myipaddr, &conn->ksnc_ipaddr,
-	       conn->ksnc_port, incarnation, cpt,
-	       (int)(sched - &sched->kss_info->ksi_scheds[0]));
+	       conn->ksnc_port, incarnation, cpt);
 
 	if (active) {
 		/* additional routes after interface exchange? */
@@ -2209,7 +2196,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		data->ioc_u32[1] = conn->ksnc_port;
 		data->ioc_u32[2] = conn->ksnc_myipaddr;
 		data->ioc_u32[3] = conn->ksnc_type;
-		data->ioc_u32[4] = conn->ksnc_scheduler->kss_info->ksi_cpt;
+		data->ioc_u32[4] = conn->ksnc_scheduler->kss_cpt;
 		data->ioc_u32[5] = rxmem;
 		data->ioc_u32[6] = conn->ksnc_peer->ksnp_id.pid;
 		ksocknal_conn_decref(conn);
@@ -2248,14 +2235,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	LASSERT(!atomic_read(&ksocknal_data.ksnd_nactive_txs));
 
-	if (ksocknal_data.ksnd_sched_info) {
-		struct ksock_sched_info *info;
-		int i;
-
-		cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info)
-			kfree(info->ksi_scheds);
-		cfs_percpt_free(ksocknal_data.ksnd_sched_info);
-	}
+	if (ksocknal_data.ksnd_schedulers)
+		cfs_percpt_free(ksocknal_data.ksnd_schedulers);
 
 	kvfree(ksocknal_data.ksnd_peers);
 
@@ -2282,10 +2263,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 static void
 ksocknal_base_shutdown(void)
 {
-	struct ksock_sched_info *info;
 	struct ksock_sched *sched;
 	int i;
-	int j;
 
 	LASSERT(!ksocknal_data.ksnd_nnets);
 
@@ -2305,22 +2284,14 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		LASSERT(list_empty(&ksocknal_data.ksnd_connd_connreqs));
 		LASSERT(list_empty(&ksocknal_data.ksnd_connd_routes));
 
-		if (ksocknal_data.ksnd_sched_info) {
-			cfs_percpt_for_each(info, i,
-					    ksocknal_data.ksnd_sched_info) {
-				if (!info->ksi_scheds)
-					continue;
+		if (ksocknal_data.ksnd_schedulers) {
+			cfs_percpt_for_each(sched, i,
+					    ksocknal_data.ksnd_schedulers) {
 
-				for (j = 0; j < info->ksi_nthreads_max; j++) {
-					sched = &info->ksi_scheds[j];
-					LASSERT(list_empty(
-						&sched->kss_tx_conns));
-					LASSERT(list_empty(
-						&sched->kss_rx_conns));
-					LASSERT(list_empty(
-						&sched->kss_zombie_noop_txs));
-					LASSERT(!sched->kss_nconns);
-				}
+				LASSERT(list_empty(&sched->kss_tx_conns));
+				LASSERT(list_empty(&sched->kss_rx_conns));
+				LASSERT(list_empty(&sched->kss_zombie_noop_txs));
+				LASSERT(!sched->kss_nconns);
 			}
 		}
 
@@ -2329,17 +2300,10 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		wake_up_all(&ksocknal_data.ksnd_connd_waitq);
 		wake_up_all(&ksocknal_data.ksnd_reaper_waitq);
 
-		if (ksocknal_data.ksnd_sched_info) {
-			cfs_percpt_for_each(info, i,
-					    ksocknal_data.ksnd_sched_info) {
-				if (!info->ksi_scheds)
-					continue;
-
-				for (j = 0; j < info->ksi_nthreads_max; j++) {
-					sched = &info->ksi_scheds[j];
+		if (ksocknal_data.ksnd_schedulers) {
+			cfs_percpt_for_each(sched, i,
+					    ksocknal_data.ksnd_schedulers)
 					wake_up_all(&sched->kss_waitq);
-				}
-			}
 		}
 
 		i = 4;
@@ -2367,7 +2331,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 static int
 ksocknal_base_startup(void)
 {
-	struct ksock_sched_info	*info;
+	struct ksock_sched *sched;
 	int rc;
 	int i;
 
@@ -2409,15 +2373,18 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	ksocknal_data.ksnd_init = SOCKNAL_INIT_DATA;
 	try_module_get(THIS_MODULE);
 
-	ksocknal_data.ksnd_sched_info = cfs_percpt_alloc(lnet_cpt_table(),
-							 sizeof(*info));
-	if (!ksocknal_data.ksnd_sched_info)
+	/* Create a scheduler block per available CPT */
+	ksocknal_data.ksnd_schedulers = cfs_percpt_alloc(lnet_cpt_table(),
+							 sizeof(*sched));
+	if (!ksocknal_data.ksnd_schedulers)
 		goto failed;
 
-	cfs_percpt_for_each(info, i, ksocknal_data.ksnd_sched_info) {
-		struct ksock_sched *sched;
+	cfs_percpt_for_each(sched, i, ksocknal_data.ksnd_schedulers) {
 		int nthrs;
 
+		/* make sure not to allocate more threads than there are
+		 * cores/CPUs in the CPT
+		 */
 		nthrs = cfs_cpt_weight(lnet_cpt_table(), i);
 		if (*ksocknal_tunables.ksnd_nscheds > 0) {
 			nthrs = min(nthrs, *ksocknal_tunables.ksnd_nscheds);
@@ -2429,27 +2396,14 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			nthrs = min(max(SOCKNAL_NSCHEDS, nthrs >> 1), nthrs);
 		}
 
-		info->ksi_nthreads_max = nthrs;
-		info->ksi_cpt = i;
-
-		if (nthrs == 0)
-			continue;
-
-		info->ksi_scheds = kzalloc_cpt(info->ksi_nthreads_max * sizeof(*sched),
-					       GFP_NOFS, i);
-		if (!info->ksi_scheds)
-			goto failed;
-
-		for (; nthrs > 0; nthrs--) {
-			sched = &info->ksi_scheds[nthrs - 1];
+		sched->kss_nthreads_max = nthrs;
+		sched->kss_cpt = i;
 
-			sched->kss_info = info;
-			spin_lock_init(&sched->kss_lock);
-			INIT_LIST_HEAD(&sched->kss_rx_conns);
-			INIT_LIST_HEAD(&sched->kss_tx_conns);
-			INIT_LIST_HEAD(&sched->kss_zombie_noop_txs);
-			init_waitqueue_head(&sched->kss_waitq);
-		}
+		spin_lock_init(&sched->kss_lock);
+		INIT_LIST_HEAD(&sched->kss_rx_conns);
+		INIT_LIST_HEAD(&sched->kss_tx_conns);
+		INIT_LIST_HEAD(&sched->kss_zombie_noop_txs);
+		init_waitqueue_head(&sched->kss_waitq);
 	}
 
 	ksocknal_data.ksnd_connd_starting = 0;
@@ -2646,37 +2600,35 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static int
-ksocknal_start_schedulers(struct ksock_sched_info *info)
+ksocknal_start_schedulers(struct ksock_sched *sched)
 {
 	int nthrs;
 	int rc = 0;
 	int i;
 
-	if (!info->ksi_nthreads) {
+	if (sched->kss_nthreads == 0) {
 		if (*ksocknal_tunables.ksnd_nscheds > 0) {
-			nthrs = info->ksi_nthreads_max;
+			nthrs = sched->kss_nthreads_max;
 		} else {
 			nthrs = cfs_cpt_weight(lnet_cpt_table(),
-					       info->ksi_cpt);
+					       sched->kss_cpt);
 			nthrs = min(max(SOCKNAL_NSCHEDS, nthrs >> 1), nthrs);
 			nthrs = min(SOCKNAL_NSCHEDS_HIGH, nthrs);
 		}
-		nthrs = min(nthrs, info->ksi_nthreads_max);
+		nthrs = min(nthrs, sched->kss_nthreads_max);
 	} else {
-		LASSERT(info->ksi_nthreads <= info->ksi_nthreads_max);
+		LASSERT(sched->kss_nthreads <= sched->kss_nthreads_max);
 		/* increase two threads if there is new interface */
-		nthrs = min(2, info->ksi_nthreads_max - info->ksi_nthreads);
+		nthrs = min(2, sched->kss_nthreads_max - sched->kss_nthreads);
 	}
 
 	for (i = 0; i < nthrs; i++) {
 		long id;
 		char name[20];
-		struct ksock_sched *sched;
 
-		id = KSOCK_THREAD_ID(info->ksi_cpt, info->ksi_nthreads + i);
-		sched = &info->ksi_scheds[KSOCK_THREAD_SID(id)];
+		id = KSOCK_THREAD_ID(sched->kss_cpt, sched->kss_nthreads + i);
 		snprintf(name, sizeof(name), "socknal_sd%02d_%02d",
-			 info->ksi_cpt, (int)(sched - &info->ksi_scheds[0]));
+			 sched->kss_cpt, (int)KSOCK_THREAD_SID(id));
 
 		rc = ksocknal_thread_start(ksocknal_scheduler,
 					   (void *)id, name);
@@ -2684,11 +2636,11 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			continue;
 
 		CERROR("Can't spawn thread %d for scheduler[%d]: %d\n",
-		       info->ksi_cpt, info->ksi_nthreads + i, rc);
+		       sched->kss_cpt, (int)KSOCK_THREAD_SID(id), rc);
 		break;
 	}
 
-	info->ksi_nthreads += i;
+	sched->kss_nthreads += i;
 	return rc;
 }
 
@@ -2703,16 +2655,16 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		return -EINVAL;
 
 	for (i = 0; i < ncpts; i++) {
-		struct ksock_sched_info *info;
+		struct ksock_sched *sched;
 		int cpt = !cpts ? i : cpts[i];
 
 		LASSERT(cpt < cfs_cpt_number(lnet_cpt_table()));
-		info = ksocknal_data.ksnd_sched_info[cpt];
+		sched = ksocknal_data.ksnd_schedulers[cpt];
 
-		if (!newif && info->ksi_nthreads > 0)
+		if (!newif && sched->kss_nthreads > 0)
 			continue;
 
-		rc = ksocknal_start_schedulers(info);
+		rc = ksocknal_start_schedulers(sched);
 		if (rc)
 			return rc;
 	}
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index c8d8acf..2e292f0 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -74,8 +74,7 @@
 # define SOCKNAL_RISK_KMAP_DEADLOCK	1
 #endif
 
-struct ksock_sched_info;
-
+/* per scheduler state */
 struct ksock_sched {				/* per scheduler state */
 	spinlock_t		kss_lock;	/* serialise */
 	struct list_head	kss_rx_conns;	/* conn waiting to be read */
@@ -85,15 +84,14 @@ struct ksock_sched {				/* per scheduler state */
 	int			kss_nconns;	/* # connections assigned to
 						 * this scheduler
 						 */
-	struct ksock_sched_info	*kss_info;	/* owner of it */
+	/* max allowed threads */
+	int			kss_nthreads_max;
+	/* number of threads */
+	int			kss_nthreads;
+	/* CPT id */
+	int			kss_cpt;
 };
 
-struct ksock_sched_info {
-	int			ksi_nthreads_max; /* max allowed threads */
-	int			ksi_nthreads;	  /* number of threads */
-	int			ksi_cpt;	  /* CPT id */
-	struct ksock_sched	*ksi_scheds;	  /* array of schedulers */
-};
 
 #define KSOCK_CPT_SHIFT			16
 #define KSOCK_THREAD_ID(cpt, sid)	(((cpt) << KSOCK_CPT_SHIFT) | (sid))
@@ -197,7 +195,7 @@ struct ksock_nal_data {
 	int			ksnd_nthreads;		/* # live threads */
 	int			ksnd_shuttingdown;	/* tell threads to exit
 							 */
-	struct ksock_sched_info	**ksnd_sched_info;	/* schedulers info */
+	struct ksock_sched	**ksnd_schedulers;	/* schedulers info */
 
 	atomic_t		ksnd_nactive_txs;	/* #active txs */
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index abb3529..581f734 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1349,7 +1349,6 @@ struct ksock_route *
 
 int ksocknal_scheduler(void *arg)
 {
-	struct ksock_sched_info *info;
 	struct ksock_sched *sched;
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
@@ -1357,13 +1356,12 @@ int ksocknal_scheduler(void *arg)
 	int nloops = 0;
 	long id = (long)arg;
 
-	info = ksocknal_data.ksnd_sched_info[KSOCK_THREAD_CPT(id)];
-	sched = &info->ksi_scheds[KSOCK_THREAD_SID(id)];
+	sched = ksocknal_data.ksnd_schedulers[KSOCK_THREAD_CPT(id)];
 
-	rc = cfs_cpt_bind(lnet_cpt_table(), info->ksi_cpt);
+	rc = cfs_cpt_bind(lnet_cpt_table(), sched->kss_cpt);
 	if (rc) {
 		CWARN("Can't set CPU partition affinity to %d: %d\n",
-		      info->ksi_cpt, rc);
+		      sched->kss_cpt, rc);
 	}
 
 	spin_lock_bh(&sched->kss_lock);
-- 
1.8.3.1
