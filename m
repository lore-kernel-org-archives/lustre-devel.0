From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:12 -0500
Subject: [lustre-devel] [PATCH 05/22] staging: lustre: lmv: remove nlink
	check in lmv_revalidate_slaves
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Remove nlink < 2 check in lmv_revalidate_slaves, because
after nlink reaches to LDISKFS_LINK_MAX (65000), the inode
nlink will be set to 1.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6984
Reviewed-on: http://review.whamcloud.com/16490
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index b1071cf..aa42066 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -220,21 +220,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 			/* refresh slave from server */
 			body = req_capsule_server_get(&req->rq_pill,
 						      &RMF_MDT_BODY);
-			LASSERT(body);
-
-			if (unlikely(body->mbo_nlink < 2)) {
-				/*
-				 * If this is bad stripe, most likely due
-				 * to the race between close(unlink) and
-				 * getattr, let's return -EONENT, so llite
-				 * will revalidate the dentry see
-				 * ll_inode_revalidate_fini()
-				 */
-				CDEBUG(D_INODE, "%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
-				       obd->obd_name, body->mbo_nlink, i,
-				       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
-				       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
-
+			if (!body) {
 				if (it.it_lock_mode && lockh) {
 					ldlm_lock_decref(lockh, it.it_lock_mode);
 					it.it_lock_mode = 0;
-- 
1.7.1
