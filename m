From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:07 -0400
Subject: [lustre-devel] [PATCH 15/15] staging: lustre: ptlrpc: quiet warning
	for 2.1/2.5 connections
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

The Lustre 2.5.4 client will print a warning about connections with
2.1.3 servers, yet they are still supposed to be interoperable.
Increase the window of warning to be up to Lustre 2.5.50, since we
do not intend to allow interoperability between 2.1 and 2.6 systems.
This was from the time when major releases like Lustre 1.4 and 1.8
were many years apart would have no chance for interoperation.

Only print this message once per client, to avoid flooding the console
for connections to many servers or frequent network reconnections.
Server versions should all be nearly the same in any case.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2528
Reviewed-on: http://review.whamcloud.com/7916
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index bf7b9d2..a4f7544 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1001,6 +1001,8 @@ finish:
 			return 0;
 		}
 	} else {
+		static bool warned;
+
 		spin_lock(&imp->imp_lock);
 		list_del(&imp->imp_conn_current->oic_item);
 		list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
@@ -1020,7 +1022,7 @@ finish:
 			goto out;
 		}
 
-		if ((ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
+		if (!warned && (ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
 		    (ocd->ocd_version > LUSTRE_VERSION_CODE +
 					LUSTRE_VERSION_OFFSET_WARN ||
 		     ocd->ocd_version < LUSTRE_VERSION_CODE -
@@ -1028,10 +1030,8 @@ finish:
 			/* Sigh, some compilers do not like #ifdef in the middle
 			 * of macro arguments
 			 */
-			const char *older = "older. Consider upgrading server or downgrading client"
-				;
-			const char *newer = "newer than client version. Consider upgrading client"
-					    ;
+			const char *older = "older than client. Consider upgrading server";
+			const char *newer = "newer than client. Consider recompiling application";
 
 			LCONSOLE_WARN("Server %s version (%d.%d.%d.%d) is much %s (%s)\n",
 				      obd2cli_tgt(imp->imp_obd),
@@ -1041,6 +1041,7 @@ finish:
 				      OBD_OCD_VERSION_FIX(ocd->ocd_version),
 				      ocd->ocd_version > LUSTRE_VERSION_CODE ?
 				      newer : older, LUSTRE_VERSION_STRING);
+			warned = true;
 		}
 
 #if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 2, 50, 0)
-- 
1.7.1
