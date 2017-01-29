From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:12 -0500
Subject: [lustre-devel] [PATCH 44/60] staging: lustre: libcfs: fix error
	messages
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Don't treat unability to set CPU partition affinity as error.
Improve those warning messages.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23307
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 4 ++--
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 5 +++--
 drivers/staging/lustre/lnet/libcfs/workitem.c          | 2 +-
 drivers/staging/lustre/lnet/selftest/module.c          | 3 ++-
 5 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 14dbc53..e2f3f72 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3546,7 +3546,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	rc = cfs_cpt_bind(lnet_cpt_table(), sched->ibs_cpt);
 	if (rc) {
-		CWARN("Failed to bind on CPT %d, please verify whether all CPUs are healthy and reload modules if necessary, otherwise your system might under risk of low performance\n",
+		CWARN("Unable to bind on CPU partition %d, please verify whether all CPUs are healthy and reload modules if necessary, otherwise your system might under risk of low performance\n",
 		      sched->ibs_cpt);
 	}
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 3531e7d..df4f55e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1414,8 +1414,8 @@ int ksocknal_scheduler(void *arg)
 
 	rc = cfs_cpt_bind(lnet_cpt_table(), info->ksi_cpt);
 	if (rc) {
-		CERROR("Can't set CPT affinity to %d: %d\n",
-		       info->ksi_cpt, rc);
+		CWARN("Can't set CPU partition affinity to %d: %d\n",
+		      info->ksi_cpt, rc);
 	}
 
 	spin_lock_bh(&sched->kss_lock);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 62ab76e..4d35a37 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -1082,8 +1082,9 @@ static int cfs_cpu_dead(unsigned int cpu)
 	}
 	spin_unlock(&cpt_data.cpt_lock);
 
-	LCONSOLE(0, "HW CPU cores: %d, npartitions: %d\n",
-		 num_online_cpus(), cfs_cpt_number(cfs_cpt_table));
+	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
+		 num_online_nodes(), num_online_cpus(),
+		 cfs_cpt_number(cfs_cpt_table));
 	return 0;
 
  failed:
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index d0512da..dbc2a9b 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -209,7 +209,7 @@ static int cfs_wi_scheduler(void *arg)
 	/* CPT affinity scheduler? */
 	if (sched->ws_cptab)
 		if (cfs_cpt_bind(sched->ws_cptab, sched->ws_cpt))
-			CWARN("Failed to bind %s on CPT %d\n",
+			CWARN("Unable to bind %s on CPU partition %d\n",
 			      sched->ws_name, sched->ws_cpt);
 
 	spin_lock(&cfs_wi_data.wi_glock);
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 71485f9..b5d556f 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -112,7 +112,8 @@ enum {
 		rc = cfs_wi_sched_create("lst_t", lnet_cpt_table(), i,
 					 nthrs, &lst_sched_test[i]);
 		if (rc) {
-			CERROR("Failed to create CPT affinity WI scheduler %d for LST\n", i);
+			CWARN("Failed to create CPU partition affinity WI scheduler %d for LST\n",
+			      i);
 			goto error;
 		}
 	}
-- 
1.8.3.1
