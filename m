From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:05 -0500
Subject: [lustre-devel] [PATCH 137/622] lustre: ptlrpc: Make CPU binding
 switchable
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-138-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

LU-6325 added CPT binding to the ptlrpc worker threads on
the servers.  This is often desirable, especially where
NUMA latencies are high, but it is not always beneficial.

If NUMA latencies are low, there is little benefit, and
sometimes it can be quite costly:

In particular, if NID-CPT hashing with routers leads to an
unbalanced workload by CPT, it is easy to end up in a
situation where the CPUs in one CPT are maxed out but
others are idle.

To this end, we add module parameters to allow disabling
the strict binding behavior, allowing threads to use all
CPUs.

This is complicated a bit because we still want separate
service partitions - The existing "no affinity" behavior
places all service threads in a single service partition,
which gives only one queue for service wakeups.

So we separate binding behavior from CPT association,
allowing us to keep multiple service partitions where
desired.

Module parameters are added to ldlm, mdt, and ost, of the
form "servicename_cpu_bind", such as "mds_rdpg_cpu_bind".

Setting them to "0" will disable the strict CPU binding
behavior for the threads in that service.

Parameters were not added for certain minor services which
do not have any CPT affinity/binding behavior today.  (This
appears to be because they are not expected to be
performance sensitive.)

cray-bug-id: LUS-6518
WC-bug-id: https://jira.whamcloud.com/browse/LU-11454
Lustre-commit: 3eb7a1dfc3e7 ("LU-11454 ptlrpc: Make CPU binding switchable")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33262
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 12 ++++++++----
 fs/lustre/ldlm/ldlm_lockd.c    |  8 +++++++-
 fs/lustre/ptlrpc/service.c     | 25 +++++++++++++++----------
 3 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index cbd524c..81a6ac9 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1480,14 +1480,16 @@ struct ptlrpc_service {
 	int				srv_watchdog_factor;
 	/** under unregister_service */
 	unsigned			srv_is_stopping:1;
+	/** Whether or not to restrict service threads to CPUs in this CPT */
+	unsigned			srv_cpt_bind:1;
 
 	/** max # request buffers */
 	int				srv_nrqbds_max;
 	/** max # request buffers in history per partition */
 	int				srv_hist_nrqbds_cpt_max;
-	/** number of CPTs this service bound on */
+	/** number of CPTs this service associated with */
 	int				srv_ncpts;
-	/** CPTs array this service bound on */
+	/** CPTs array this service associated with */
 	u32				*srv_cpts;
 	/** 2^srv_cptab_bits >= cfs_cpt_numbert(srv_cptable) */
 	int				srv_cpt_bits;
@@ -1934,8 +1936,8 @@ struct ptlrpc_service_thr_conf {
 	 * other members of this structure.
 	 */
 	unsigned int			tc_nthrs_user;
-	/* set NUMA node affinity for service threads */
-	unsigned int			tc_cpu_affinity;
+	/* bind service threads to only CPUs in their associated CPT */
+	unsigned int			tc_cpu_bind;
 	/* Tags for lu_context associated with service thread */
 	u32				tc_ctx_tags;
 };
@@ -1944,6 +1946,8 @@ struct ptlrpc_service_cpt_conf {
 	struct cfs_cpt_table		*cc_cptable;
 	/* string pattern to describe CPTs for a service */
 	char				*cc_pattern;
+	/* whether or not to have per-CPT service partitions */
+	bool				cc_affinity;
 };
 
 struct ptlrpc_service_conf {
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index b50a3f7..204b11b 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -49,6 +49,11 @@
 module_param(ldlm_num_threads, int, 0444);
 MODULE_PARM_DESC(ldlm_num_threads, "number of DLM service threads to start");
 
+static unsigned int ldlm_cpu_bind = 1;
+module_param(ldlm_cpu_bind, uint, 0444);
+MODULE_PARM_DESC(ldlm_cpu_bind,
+		 "bind DLM service threads to particular CPU partitions");
+
 static char *ldlm_cpts;
 module_param(ldlm_cpts, charp, 0444);
 MODULE_PARM_DESC(ldlm_cpts, "CPU partitions ldlm threads should run on");
@@ -1006,11 +1011,12 @@ static int ldlm_setup(void)
 			.tc_nthrs_base		= LDLM_NTHRS_BASE,
 			.tc_nthrs_max		= LDLM_NTHRS_MAX,
 			.tc_nthrs_user		= ldlm_num_threads,
-			.tc_cpu_affinity	= 1,
+			.tc_cpu_bind		= ldlm_cpu_bind,
 			.tc_ctx_tags		= LCT_MD_THREAD | LCT_DT_THREAD,
 		},
 		.psc_cpt		= {
 			.cc_pattern		= ldlm_cpts,
+			.cc_affinity		= true,
 		},
 		.psc_ops		= {
 			.so_req_handler		= ldlm_callback_handler,
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index a9155b2..b94ed6a 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -573,7 +573,13 @@ struct ptlrpc_service *
 	if (!cptable)
 		cptable = cfs_cpt_tab;
 
-	if (!conf->psc_thr.tc_cpu_affinity) {
+	if (conf->psc_thr.tc_cpu_bind > 1) {
+		CERROR("%s: Invalid cpu bind value %d, only 1 or 0 allowed\n",
+		       conf->psc_name, conf->psc_thr.tc_cpu_bind);
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (!cconf->cc_affinity) {
 		ncpts = 1;
 	} else {
 		ncpts = cfs_cpt_number(cptable);
@@ -611,6 +617,7 @@ struct ptlrpc_service *
 	service->srv_cptable = cptable;
 	service->srv_cpts = cpts;
 	service->srv_ncpts = ncpts;
+	service->srv_cpt_bind = conf->psc_thr.tc_cpu_bind;
 
 	service->srv_cpt_bits = 0; /* it's zero already, easy to read... */
 	while ((1 << service->srv_cpt_bits) < cfs_cpt_number(cptable))
@@ -646,7 +653,7 @@ struct ptlrpc_service *
 	service->srv_ops = conf->psc_ops;
 
 	for (i = 0; i < ncpts; i++) {
-		if (!conf->psc_thr.tc_cpu_affinity)
+		if (!cconf->cc_affinity)
 			cpt = CFS_CPT_ANY;
 		else
 			cpt = cpts ? cpts[i] : i;
@@ -2105,14 +2112,12 @@ static int ptlrpc_main(void *arg)
 	thread->t_pid = current->pid;
 	unshare_fs_struct();
 
-	/* NB: we will call cfs_cpt_bind() for all threads, because we
-	 * might want to run lustre server only on a subset of system CPUs,
-	 * in that case ->scp_cpt is CFS_CPT_ANY
-	 */
-	rc = cfs_cpt_bind(svc->srv_cptable, svcpt->scp_cpt);
-	if (rc != 0) {
-		CWARN("%s: failed to bind %s on CPT %d\n",
-		      svc->srv_name, thread->t_name, svcpt->scp_cpt);
+	if (svc->srv_cpt_bind) {
+		rc = cfs_cpt_bind(svc->srv_cptable, svcpt->scp_cpt);
+		if (rc != 0) {
+			CWARN("%s: failed to bind %s on CPT %d\n",
+			      svc->srv_name, thread->t_name, svcpt->scp_cpt);
+		}
 	}
 
 	ginfo = groups_alloc(0);
-- 
1.8.3.1
