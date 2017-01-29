From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:47 -0500
Subject: [lustre-devel] [PATCH 19/60] staging: lustre: llite: handle
	inactive OSTs better in statfs
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Change the order of checks for inactive OSCs in lov_prep_statfs_set()
so that administratively disabled OSTs do not generate any output in
"lfs df" at all, to avoid needlessly cluttering the output.

Enable the lazystatfs mount option by default, so that "df" does not
hang when an OST is temporarily offline.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7759
Reviewed-on: http://review.whamcloud.com/19195
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 1 +
 drivers/staging/lustre/lustre/lov/lov_request.c | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 769b307..0a87058 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -103,6 +103,7 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	sbi->ll_flags |= LL_SBI_CHECKSUM;
 
 	sbi->ll_flags |= LL_SBI_LRU_RESIZE;
+	sbi->ll_flags |= LL_SBI_LAZYSTATFS;
 
 	for (i = 0; i <= LL_PROCESS_HIST_MAX; i++) {
 		spin_lock_init(&sbi->ll_rw_extents_info.pp_extents[i].
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index d43cc88..3a74791 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -344,9 +344,6 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 			continue;
 		}
 
-		if (!lov->lov_tgts[i]->ltd_active)
-			lov_check_and_wait_active(lov, i);
-
 		/* skip targets that have been explicitly disabled by the
 		 * administrator
 		 */
@@ -355,6 +352,9 @@ int lov_prep_statfs_set(struct obd_device *obd, struct obd_info *oinfo,
 			continue;
 		}
 
+		if (!lov->lov_tgts[i]->ltd_active)
+			lov_check_and_wait_active(lov, i);
+
 		req = kzalloc(sizeof(*req), GFP_NOFS);
 		if (!req) {
 			rc = -ENOMEM;
-- 
1.8.3.1
