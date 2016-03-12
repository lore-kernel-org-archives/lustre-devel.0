From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:35 -0500
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: realign some code in
	lnet selftest so its readable
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Two places to align the code so it is easier to read.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/console.c   |    2 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 17d0d13..6ec8952 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -733,7 +733,7 @@ lstcon_group_list(int index, int len, char __user *name_up)
 	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
 		if (!index--) {
 			return copy_to_user(name_up, grp->grp_name, len) ?
-			       -EFAULT : 0;
+					    -EFAULT : 0;
 		}
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 81a4504..438fca2 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -86,8 +86,8 @@ ping_client_fini(sfw_test_instance_t *tsi)
 }
 
 static int
-ping_client_prep_rpc(sfw_test_unit_t *tsu,
-		     lnet_process_id_t dest, srpc_client_rpc_t **rpc)
+ping_client_prep_rpc(sfw_test_unit_t *tsu, lnet_process_id_t dest,
+		     srpc_client_rpc_t **rpc)
 {
 	srpc_ping_reqst_t *req;
 	sfw_test_instance_t *tsi = tsu->tsu_instance;
-- 
1.7.1
