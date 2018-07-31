From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:02 -0400
Subject: [lustre-devel] [PATCH 10/31] lustre: lnet: removal of obsolete LNDs
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Obsolete LNDs were already removed. Commented out the name<->network
number mapping for the obsolete LNDs.

Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
WC-id: https://jira.whamcloud.com/browse/LU-8769
Reviewed-on: https://review.whamcloud.com/23621
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/uapi/linux/lnet/nidstr.h    | 18 +++++++++---------
 drivers/staging/lustre/lnet/lnet/api-ni.c              |  6 ------
 2 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
index 882074e..3354e5a 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
@@ -38,18 +38,18 @@ enum {
 	 * Only add to these values (i.e. don't ever change or redefine them):
 	 * network addresses depend on them...
 	 */
-	QSWLND		= 1,
+	/*QSWLND	= 1, removed v2_7_50			*/
 	SOCKLND		= 2,
-	GMLND		= 3,
-	PTLLND		= 4,
+	/*GMLND		= 3, removed v2_0_0-rc1a-16-gc660aac	*/
+	/*PTLLND	= 4, removed v2_7_50			*/
 	O2IBLND		= 5,
-	CIBLND		= 6,
-	OPENIBLND	= 7,
-	IIBLND		= 8,
+	/*CIBLND        = 6, removed v2_0_0-rc1a-175-gd2b8a0e	*/
+	/*OPENIBLND	= 7, removed v2_0_0-rc1a-175-gd2b8a0e	*/
+	/*IIBLND	= 8, removed v2_0_0-rc1a-175-gd2b8a0e	*/
 	LOLND		= 9,
-	RALND		= 10,
-	VIBLND		= 11,
-	MXLND		= 12,
+	/*RALND		= 10, removed v2_7_50_0-34-g8be9e41	*/
+	/*VIBLND	= 11, removed v2_0_0-rc1a-175-gd2b8a0e	*/
+	/*MXLND		= 12, removed v2_7_50_0-34-g8be9e41	*/
 	GNILND		= 13,
 	GNIIPLND	= 14,
 };
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e517893..a949ac2 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1207,12 +1207,6 @@ struct lnet_ni  *
 
 	LASSERT(libcfs_isknown_lnd(lnd_type));
 
-	if (lnd_type == CIBLND || lnd_type == OPENIBLND ||
-	    lnd_type == IIBLND || lnd_type == VIBLND) {
-		CERROR("LND %s obsoleted\n", libcfs_lnd2str(lnd_type));
-		goto failed0;
-	}
-
 	/* Make sure this new NI is unique. */
 	lnet_net_lock(LNET_LOCK_EX);
 	rc = lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis);
-- 
1.8.3.1
