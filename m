From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:04 -0500
Subject: [lustre-devel] [PATCH 28/40] staging: lustre: return -EEXIST if NI
	is not unique
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Return -EEXIST and not -EINVAL when trying to add a
network interface which is not unique.

Some minor cleanup in api-ni.c

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5875
Reviewed-on: http://review.whamcloud.com/13056
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 9b00bc1..ed167c8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1213,7 +1213,7 @@ static int
 lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 		   __s32 peer_cr, __s32 peer_buf_cr, __s32 credits)
 {
-	int rc = 0;
+	int rc = -EINVAL;
 	__u32 lnd_type;
 	lnd_t *lnd;
 	struct lnet_tx_queue *tq;
@@ -1231,19 +1231,19 @@ lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 
 	/* Make sure this new NI is unique. */
 	lnet_net_lock(LNET_LOCK_EX);
-	if (!lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis)) {
+	rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis);
+	lnet_net_unlock(LNET_LOCK_EX);
+	if (!rc) {
 		if (lnd_type == LOLND) {
-			lnet_net_unlock(LNET_LOCK_EX);
 			lnet_ni_free(ni);
 			return 0;
 		}
-		lnet_net_unlock(LNET_LOCK_EX);
 
 		CERROR("Net %s is not unique\n",
 		       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
+		rc = -EEXIST;
 		goto failed0;
 	}
-	lnet_net_unlock(LNET_LOCK_EX);
 
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 	lnd = lnet_find_lnd_by_type(lnd_type);
@@ -1259,6 +1259,7 @@ lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 			CERROR("Can't load LND %s, module %s, rc=%d\n",
 			       libcfs_lnd2str(lnd_type),
 			       libcfs_lnd2modname(lnd_type), rc);
+			rc = -EINVAL;
 			goto failed0;
 		}
 	}
@@ -1348,7 +1349,7 @@ lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 	return 0;
 failed0:
 	lnet_ni_free(ni);
-	return -EINVAL;
+	return rc;
 }
 
 static int
@@ -1495,7 +1496,7 @@ int
 LNetNIInit(lnet_pid_t requested_pid)
 {
 	int im_a_router = 0;
-	int rc, rc2;
+	int rc;
 	int ni_count;
 	lnet_ping_info_t *pinfo;
 	lnet_handle_md_t md_handle;
@@ -1584,10 +1585,7 @@ LNetNIInit(lnet_pid_t requested_pid)
 	return 0;
 
  failed4:
-	lnet_ping_md_unlink(pinfo, &md_handle);
-	lnet_ping_info_free(pinfo);
-	rc2 = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(rc2 == 0);
+	lnet_ping_target_fini();
  failed3:
 	the_lnet.ln_refcount = 0;
 	lnet_acceptor_stop();
-- 
1.7.1
