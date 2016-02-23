From: James Simmons <jsimmons@infradead.org>
Date: Tue, 23 Feb 2016 11:48:31 -0500
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: update format for
	lnet_lib_init/exit comment
In-Reply-To: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
References: <1456246111-26263-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456246111-26263-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andreas Dilger <andreas.dilger@intel.com>

The documentation about the return values for lnet_lib_init
and lnet_lib_exit was in the old style format. Bring it in
sync with the rest of the LNet core. Broken out of patch 16787.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6204
Reviewed-on: http://review.whamcloud.com/16787
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e26886e..c4d5f2f 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1389,7 +1389,8 @@ failed:
  * lnet_lib_exit() after a call to lnet_lib_init(), if and only if the
  * latter returned 0. It must be called exactly once.
  *
- * \return 0 on success, and -ve on failures.
+ * \retval 0 on success
+ * \retval -ve on failures.
  */
 int lnet_lib_init(void)
 {
-- 
1.7.1
