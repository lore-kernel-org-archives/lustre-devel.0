From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:46 -0500
Subject: [lustre-devel] [PATCH 21/34] staging: lustre: lnet: change lnet_t
	to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  | 2 +-
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 4 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 37b9d66..4ffe79c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -41,7 +41,7 @@
 #include "lib-types.h"
 #include "lib-dlc.h"
 
-extern lnet_t	the_lnet;	/* THE network */
+extern struct lnet the_lnet;	/* THE network */
 
 #if (BITS_PER_LONG == 32)
 /* 2 CPTs, allowing more CPTs might make us under memory pressure */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e00bd38..5bf1819 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -545,7 +545,7 @@ struct lnet_msg_container {
 #define LNET_RC_STATE_RUNNING		1	/* started up OK */
 #define LNET_RC_STATE_STOPPING		2	/* telling thread to stop */
 
-typedef struct {
+struct lnet {
 	/* CPU partition table of LNet */
 	struct cfs_cpt_table		 *ln_cpt_table;
 	/* number of CPTs in ln_cpt_table */
@@ -648,6 +648,6 @@ struct lnet_msg_container {
 	 */
 	wait_queue_head_t		  ln_rc_waitq;
 
-} lnet_t;
+};
 
 #endif
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index c03e701..024b8e3 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -39,7 +39,7 @@
 
 #define D_LNI D_CONSOLE
 
-lnet_t the_lnet;			   /* THE state of the network */
+struct lnet the_lnet;		/* THE state of the network */
 EXPORT_SYMBOL(the_lnet);
 
 static char *ip2nets = "";
-- 
1.8.3.1
