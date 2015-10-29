From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Thu, 29 Oct 2015 02:57:33 +0200
Subject: [lustre-devel] [PATCH v3 3/5] staging: lustre: workitem.c: replace
 IS_PO2 by is_power_of_2
In-Reply-To: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <5f3bb74fa1c407ecc97e27d2adde7cec8a3d8afa.1446079745.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. It is more accurate to use
is_power_of_2 since it returns 1 for numbers that are powers
of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
powers of 2.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
v2:
        -changed commit message
	-added Andreas Reviewed by tag
v3:
	-no change

 drivers/staging/lustre/lustre/libcfs/workitem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index e1143a5..268dd68 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -325,7 +325,7 @@ cfs_wi_sched_destroy(struct cfs_wi_sched *sched)
 
 	spin_lock(&cfs_wi_data.wi_glock);
 	while (sched->ws_nthreads > 0) {
-		CDEBUG(IS_PO2(++i) ? D_WARNING : D_NET,
+		CDEBUG(is_power_of_2(++i) ? D_WARNING : D_NET,
 		       "waiting for %d threads of WI sched[%s] to terminate\n",
 		       sched->ws_nthreads, sched->ws_name);
 
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
