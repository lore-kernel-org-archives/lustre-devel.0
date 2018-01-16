From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 16 Jan 2018 10:34:25 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: avoid uninitialized
 return value
Message-ID: <20180116093511.3197459-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, NeilBrown <neilb@suse.com>, Tejun Heo <tj@kernel.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

gcc warns that the latest workqueue change leads to returning an
uninitialized variable:

drivers/staging/lustre/lnet/selftest/module.c: In function 'lnet_selftest_init':
drivers/staging/lustre/lnet/selftest/module.c:98:10: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]

A failure from alloc_ordered_workqueue() tends to indicate an
out-of-memory condition, so return -ENOMEM in both cases.
The second error path was a preexisting bug, where we always
returned zero after a kvmalloc_array() failure.

Fixes: 6106c0f82481 ("staging: lustre: lnet: convert selftest to use workqueues")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lnet/selftest/module.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index aa6bfd5baf2f..c8d999e64f28 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -95,15 +95,17 @@ lnet_selftest_init(void)
 	lst_serial_wq = alloc_ordered_workqueue("lst_s", 0);
 	if (!lst_serial_wq) {
 		CERROR("Failed to create serial WI scheduler for LST\n");
-		return rc;
+		return -ENOMEM;
 	}
 	lst_init_step = LST_INIT_WI_SERIAL;
 
 	nscheds = cfs_cpt_number(lnet_cpt_table());
 	lst_test_wq = kvmalloc_array(nscheds, sizeof(lst_test_wq[0]),
 					GFP_KERNEL | __GFP_ZERO);
-	if (!lst_test_wq)
+	if (!lst_test_wq) {
+		rc = -ENOMEM;
 		goto error;
+	}
 
 	lst_init_step = LST_INIT_WI_TEST;
 	for (i = 0; i < nscheds; i++) {
@@ -116,6 +118,7 @@ lnet_selftest_init(void)
 		if (!lst_test_wq[i]) {
 			CWARN("Failed to create CPU partition affinity WI scheduler %d for LST\n",
 			      i);
+			rc = -ENOMEM;
 			goto error;
 		}
 		attrs.nice = 0;
-- 
2.9.0
