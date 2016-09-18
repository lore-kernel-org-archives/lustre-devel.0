From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:13 -0400
Subject: [lustre-devel] [PATCH 014/124] staging: lustre: lmv: release locks
	if lmv_intent_lock() fails
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In lmv_intent_lock() if we will return an error then first release any
locks referenced by the intent.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5431
Reviewed-on: http://review.whamcloud.com/11319
Reviewed-by: wang di <di.wang@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 85cc5cb..fd3dc7c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -533,5 +533,27 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 				     extra_lock_flags);
 	else
 		LBUG();
+
+	if (rc < 0) {
+		struct lustre_handle lock_handle;
+
+		if (it->it_lock_mode) {
+			lock_handle.cookie = it->it_lock_handle;
+			ldlm_lock_decref(&lock_handle, it->it_lock_mode);
+		}
+
+		it->it_lock_handle = 0;
+		it->it_lock_mode = 0;
+
+		if (it->it_remote_lock_mode) {
+			lock_handle.cookie = it->it_remote_lock_handle;
+			ldlm_lock_decref(&lock_handle,
+					 it->it_remote_lock_mode);
+		}
+
+		it->it_remote_lock_handle = 0;
+		it->it_remote_lock_mode = 0;
+	}
+
 	return rc;
 }
-- 
1.7.1
