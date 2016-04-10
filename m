From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:31 -0400
Subject: [lustre-devel] [PATCH 08/17] staging: lustre: obd: MDT mount fails
	on MDS w/o MGS on it
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

If we specify multiple --mgsnode for a MDT, when we start MDS upon
it while MGS is no the other node, the MGC import connection will
always select the local nid (which is one of the candidate mgsnode)
since it think its the closest connection.

This patch treats further --mgsnode nids as failover nids, so that
multiple import connections are added for the MGC import.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3829
Reviewed-on: http://review.whamcloud.com/7509
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index d3e28a3..9474aa9 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -307,7 +307,8 @@ int lustre_start_mgc(struct super_block *sb)
 	while (class_parse_nid(ptr, &nid, &ptr) == 0) {
 		rc = do_lcfg(mgcname, nid,
 			     LCFG_ADD_UUID, niduuid, NULL, NULL, NULL);
-		i++;
+		if (!rc)
+			i++;
 		/* Stop at the first failover nid */
 		if (*ptr == ':')
 			break;
@@ -345,16 +346,18 @@ int lustre_start_mgc(struct super_block *sb)
 		sprintf(niduuid, "%s_%x", mgcname, i);
 		j = 0;
 		while (class_parse_nid_quiet(ptr, &nid, &ptr) == 0) {
-			j++;
-			rc = do_lcfg(mgcname, nid,
-				     LCFG_ADD_UUID, niduuid, NULL, NULL, NULL);
+			rc = do_lcfg(mgcname, nid, LCFG_ADD_UUID, niduuid,
+				     NULL, NULL, NULL);
+			if (!rc)
+				++j;
 			if (*ptr == ':')
 				break;
 		}
 		if (j > 0) {
 			rc = do_lcfg(mgcname, 0, LCFG_ADD_CONN,
 				     niduuid, NULL, NULL, NULL);
-			i++;
+			if (!rc)
+				i++;
 		} else {
 			/* at ":/fsname" */
 			break;
-- 
1.7.1
