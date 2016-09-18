From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:00 -0400
Subject: [lustre-devel] [PATCH 001/124] staging: lustre: llite: fix
	ll_statahead_thread() problems on failure
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Li Xi <lixi@ddn.com>

When ll_prep_md_op_data() fails, ll_statahead_thread() does not
release reference of sai and parent dentry. It does not wake
up parent thread either. This patch fixes these problems.

Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5274
Reviewed-on: http://review.whamcloud.com/10940
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/statahead.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 4ac0d6a..016463b 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1050,8 +1050,10 @@ static int ll_statahead_thread(void *arg)
 
 	op_data = ll_prep_md_op_data(NULL, dir, dir, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, dir);
-	if (IS_ERR(op_data))
-		return PTR_ERR(op_data);
+	if (IS_ERR(op_data)) {
+		rc = PTR_ERR(op_data);
+		goto out_put;
+	}
 
 	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
 
@@ -1239,7 +1241,9 @@ do_it:
 		}
 	}
 out:
+	ll_dir_chain_fini(&chain);
 	ll_finish_md_op_data(op_data);
+out_put:
 	if (sai->sai_agl_valid) {
 		spin_lock(&plli->lli_agl_lock);
 		thread_set_flags(agl_thread, SVC_STOPPING);
@@ -1255,7 +1259,6 @@ out:
 		/* Set agl_thread flags anyway. */
 		thread_set_flags(&sai->sai_agl_thread, SVC_STOPPED);
 	}
-	ll_dir_chain_fini(&chain);
 	spin_lock(&plli->lli_sa_lock);
 	if (!list_empty(&sai->sai_entries_received)) {
 		thread_set_flags(thread, SVC_STOPPING);
@@ -1272,9 +1275,9 @@ out:
 	wake_up(&sai->sai_waitq);
 	wake_up(&thread->t_ctl_waitq);
 	ll_sai_put(sai);
-	dput(parent);
 	CDEBUG(D_READA, "statahead thread stopped: sai %p, parent %pd\n",
 	       sai, parent);
+	dput(parent);
 	return rc;
 }
 
-- 
1.7.1
