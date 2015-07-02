From: Ben Evans <bevans@cray.com>
Date: Thu, 2 Jul 2015 10:18:48 -0500
Subject: [lustre-devel] [PATCH] LU-3677 mdt: Set HSM dirty open-for-write
	file when	evicted.
Message-ID: <20150702151848.GA26896@lusbld01.us.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix regression introduced by LU-1303 (5165cdd). Previously,
MDS_CLOSE_CLEANUP was used to detect file closing, due to eviction.
This flag is no more since 5165cdd.

It completely removed this symbol.

Signed-off-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Change-Id: I20e18103fe085672f499c956e831564e45bd5200
Reviewed-on: http://review.whamcloud.com/7195
Tested-by: Hudson
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Tested-by: Maloo <whamcloud.maloo@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4d72d6e..c039cbc 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2390,7 +2390,7 @@ enum mds_op_bias {
 	MDS_PERM_BYPASS		= 1 << 3,
 	MDS_SOM			= 1 << 4,
 	MDS_QUOTA_IGNORE	= 1 << 5,
-	MDS_CLOSE_CLEANUP	= 1 << 6,
+	/* Was MDS_CLOSE_CLEANUP	= (1 << 6), No more used */
 	MDS_KEEP_ORPHAN		= 1 << 7,
 	MDS_RECOV_OPEN		= 1 << 8,
 	MDS_DATA_MODIFIED	= 1 << 9,
-- 
1.6.5.6
