From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:38 -0400
Subject: [lustre-devel] [PATCH 15/17] staging: lustre: lov: Don't wait for
	active target with OBD_STATFS_NODELAY
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <Andriy_Skulysh@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andriy Skulysh <Andriy_Skulysh@xyratex.com>

Patch for LU-631 which was landed before the upstream merge broke
OBD_STATFS_NODELAY behaviour. It adds unnecessary delay while
running df command with inactive OSTs. We shouldn't try to recover
connection to OST in this case.

Signed-off-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4010
Reviewed-on: http://review.whamcloud.com/7762
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_request.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 7178a02..475ca2f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -716,12 +716,15 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 		struct lov_request *req;
 
 		if (!lov->lov_tgts[i] ||
-		    (!lov_check_and_wait_active(lov, i) &&
-		     (oinfo->oi_flags & OBD_STATFS_NODELAY))) {
+		    (oinfo->oi_flags & OBD_STATFS_NODELAY &&
+		     !lov->lov_tgts[i]->ltd_active)) {
 			CDEBUG(D_HA, "lov idx %d inactive\n", i);
 			continue;
 		}
 
+		if (!lov->lov_tgts[i]->ltd_active)
+			lov_check_and_wait_active(lov, i);
+
 		/* skip targets that have been explicitly disabled by the
 		 * administrator
 		 */
-- 
1.7.1
