From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:08 -0500
Subject: [lustre-devel] [PATCH 05/34] staging: lustre: lnet: change
	lstcon_test_ent_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_test_ent_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index ec243d7..f197eb3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -98,11 +98,11 @@ struct lstcon_ndlist_ent {
 	int	nle_nunknown;	/* # of unknown nodes */
 };				/*** node_list entry, for list_batch command */
 
-typedef struct {
+struct lstcon_test_ent {
 	int	tse_type;       /* test type */
 	int	tse_loop;       /* loop count */
 	int	tse_concur;     /* concurrency of test */
-} lstcon_test_ent_t;		/*** test summary entry, for
+};				/*** test summary entry, for
 				 *** list_batch command */
 
 typedef struct {
@@ -118,7 +118,7 @@ struct lstcon_ndlist_ent {
 	struct lstcon_ndlist_ent   tbe_srv_nle;	/* server (group) node_list
 						 * entry */
 	union {
-		lstcon_test_ent_t  tbe_test;	/* test entry */
+		struct lstcon_test_ent	tbe_test; /* test entry */
 		lstcon_batch_ent_t tbe_batch;	/* batch entry */
 	} u;
 } lstcon_test_batch_ent_t;	/*** test/batch verbose information entry,
-- 
1.8.3.1
