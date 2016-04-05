From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:51 -0400
Subject: [lustre-devel] [PATCH 06/18] staging: lustre: hsm: Fix lu_ref for
	lease handle
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

The lu_ref was not being decremented when releasing the
lease handle.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/7243
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: jacques-Charles Lafoucriere <jacques-charles.lafoucriere@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c  |    4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02b5783..000ea58 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -908,7 +908,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 		lock_res_and_lock(lock);
 		cancelled = ldlm_is_cancel(lock);
 		unlock_res_and_lock(lock);
-		ldlm_lock_put(lock);
+		LDLM_LOCK_PUT(lock);
 	}
 
 	CDEBUG(D_INODE, "lease for " DFID " broken? %d\n",
@@ -2509,7 +2509,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 					rc = och->och_flags &
 						(FMODE_READ | FMODE_WRITE);
 				unlock_res_and_lock(lock);
-				ldlm_lock_put(lock);
+				LDLM_LOCK_PUT(lock);
 			}
 		}
 		mutex_unlock(&lli->lli_och_mutex);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index be0acf7..53cd56f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -454,7 +454,7 @@ static void mdc_hsm_release_pack(struct ptlrpc_request *req,
 		lock = ldlm_handle2lock(&op_data->op_lease_handle);
 		if (lock) {
 			data->cd_handle = lock->l_remote_handle;
-			ldlm_lock_put(lock);
+			LDLM_LOCK_PUT(lock);
 		}
 		ldlm_cli_cancel(&op_data->op_lease_handle, LCF_LOCAL);
 
-- 
1.7.1
