From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:30 -0400
Subject: [lustre-devel] [PATCH 34/41] staging: lustre: ldlm: cancel aged
	locks for LRUR
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

It doesn't make sense to keep the very aged lock even with the
LRUR policy. This patch decreased the default ns_max_age from 10
hours to 65 minutes and changed LRUR policy to cancel very aged
locks.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6529
Reviewed-on: http://review.whamcloud.com/14856
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    8 ++++++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index d035344..1c6b7b8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -59,7 +59,7 @@ struct obd_device;
 #define OBD_LDLM_DEVICENAME  "ldlm"
 
 #define LDLM_DEFAULT_LRU_SIZE (100 * num_online_cpus())
-#define LDLM_DEFAULT_MAX_ALIVE (cfs_time_seconds(36000))
+#define LDLM_DEFAULT_MAX_ALIVE (cfs_time_seconds(3900)) /* 65 min */
 #define LDLM_DEFAULT_PARALLEL_AST_LIMIT 1024
 
 /**
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 98730a3..ac1927c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1182,6 +1182,14 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 	if (count && added >= count)
 		return LDLM_POLICY_KEEP_LOCK;
 
+	/*
+	 * Despite of the LV, It doesn't make sense to keep the lock which
+	 * is unused for ns_max_age time.
+	 */
+	if (cfs_time_after(cfs_time_current(),
+			   cfs_time_add(lock->l_last_used, ns->ns_max_age)))
+		return LDLM_POLICY_CANCEL_LOCK;
+
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
 	la = cfs_duration_sec(cfs_time_sub(cur, lock->l_last_used));
-- 
1.7.1
