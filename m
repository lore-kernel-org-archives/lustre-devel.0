From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:03 -0500
Subject: [lustre-devel] [PATCH 495/622] lustre: obdclass: qos penalties
 miscalculated
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-496-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

In lqos_calc_penalties(), the penalty_per_obj is miscalculated.

Fixes: e6dd0ec9bcd2 ("lustre: lmv: share object alloc QoS code with LMV")

WC-bug-id: https://jira.whamcloud.com/browse/LU-12495
Lustre-commit: 9130d05de4e2 ("LU-12495 obdclass: qos penalties miscalculated")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36269
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_qos.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/lu_qos.c b/fs/lustre/obdclass/lu_qos.c
index e77e81d..13ab4a7 100644
--- a/fs/lustre/obdclass/lu_qos.c
+++ b/fs/lustre/obdclass/lu_qos.c
@@ -323,7 +323,7 @@ int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
 		 * per-tgt penalty is
 		 * prio * bavail * iavail / (num_tgt - 1) / 2
 		 */
-		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia;
+		tgt->ltd_qos.ltq_penalty_per_obj = prio_wide * ba * ia >> 8;
 		do_div(tgt->ltd_qos.ltq_penalty_per_obj, num_active);
 		tgt->ltd_qos.ltq_penalty_per_obj >>= 1;
 
@@ -357,7 +357,7 @@ int lqos_calc_penalties(struct lu_qos *qos, struct lu_tgt_descs *ltd,
 	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
 		ba = svr->lsq_bavail;
 		ia = svr->lsq_iavail;
-		svr->lsq_penalty_per_obj = prio_wide * ba  * ia;
+		svr->lsq_penalty_per_obj = prio_wide * ba  * ia >> 8;
 		do_div(ba, svr->lsq_tgt_count * num_active);
 		svr->lsq_penalty_per_obj >>= 1;
 
-- 
1.8.3.1
