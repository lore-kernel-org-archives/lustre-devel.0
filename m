From: Ben Evans <bevans@cray.com>
Date: Tue, 7 Jul 2015 10:32:34 -0500
Subject: [lustre-devel] [PATCH] [PATCH] staging/lustre: Remove unused
	MDS_CLOSE_CLEANUP	define
Message-ID: <20150707153234.GA1872@lusbld01.us.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Previously, MDS_CLOSE_CLEANUP was used to detect file closing,
due to eviction. This flag is no longer used.

Signed-off-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Intel-bug-ID: http://jira.hpdd.intel.com/browse/LU-3677
Reviewed-on: http://review.whamcloud.com/7195
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Ben Evans <bevans@cray.com>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4d72d6e..bea70cb 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2390,7 +2390,7 @@ enum mds_op_bias {
 	MDS_PERM_BYPASS		= 1 << 3,
 	MDS_SOM			= 1 << 4,
 	MDS_QUOTA_IGNORE	= 1 << 5,
-	MDS_CLOSE_CLEANUP	= 1 << 6,
+	/* MDS_CLOSE_CLEANUP = 1 << 6, obsolete since 2.4.0 */
 	MDS_KEEP_ORPHAN		= 1 << 7,
 	MDS_RECOV_OPEN		= 1 << 8,
 	MDS_DATA_MODIFIED	= 1 << 9,
-- 
1.6.5.6
