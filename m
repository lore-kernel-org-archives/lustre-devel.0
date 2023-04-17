Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9EA2CC77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:05:37 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T4K30FYz22QX;
	Mon, 17 Apr 2023 06:51:45 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T0x4Q0tz1yDG
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:48:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 919EC1008491;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 903F4379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:11 -0400
Message-Id: <1681739243-29375-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/27] lustre: statahead: statahead thread
 doesn't stop
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

Add a barrier to ensure sai_task changing can be seen
when access it without locking. Else the statahead
thread could sleep forever since wake_up was lost.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15660
Lustre-commit: b977caa2dc7dddcec ("LU-15660 statahead: statahead thread doesn't stop")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47673
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/statahead.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index e6ea2ee..12d8266 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1005,7 +1005,8 @@ static int ll_statahead_thread(void *arg)
 		goto out;
 	}
 
-	while (pos != MDS_DIR_END_OFF && sai->sai_task) {
+	/* matches smp_store_release() in ll_deauthorize_statahead() */
+	while (pos != MDS_DIR_END_OFF && smp_load_acquire(&sai->sai_task)) {
 		struct lu_dirpage *dp;
 		struct lu_dirent *ent;
 
@@ -1029,7 +1030,9 @@ static int ll_statahead_thread(void *arg)
 
 		dp = page_address(page);
 		for (ent = lu_dirent_start(dp);
-		     ent && sai->sai_task && !sa_low_hit(sai);
+		     /* matches smp_store_release() in ll_deauthorize_statahead() */
+		     ent && smp_load_acquire(&sai->sai_task) &&
+		     !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
 			struct lu_fid fid;
 			u64 hash;
@@ -1081,7 +1084,10 @@ static int ll_statahead_thread(void *arg)
 			fid_le_to_cpu(&fid, &ent->lde_fid);
 
 			while (({set_current_state(TASK_IDLE);
-				 sai->sai_task; })) {
+				 /* matches smp_store_release() in
+				  * ll_deauthorize_statahead()
+				  */
+				 smp_load_acquire(&sai->sai_task); })) {
 				spin_lock(&lli->lli_agl_lock);
 				while (sa_sent_full(sai) &&
 				       !agl_list_empty(sai)) {
@@ -1163,7 +1169,8 @@ static int ll_statahead_thread(void *arg)
 	 * for file release closedir() call to stop me.
 	 */
 	while (({set_current_state(TASK_IDLE);
-		 sai->sai_task; })) {
+		/* matches smp_store_release() in ll_deauthorize_statahead() */
+		smp_load_acquire(&sai->sai_task); })) {
 		schedule();
 	}
 	__set_current_state(TASK_RUNNING);
@@ -1244,7 +1251,8 @@ void ll_deauthorize_statahead(struct inode *dir, void *key)
 		 */
 		struct task_struct *task = sai->sai_task;
 
-		sai->sai_task = NULL;
+		/* matches smp_load_acquire() in ll_statahead_thread() */
+		smp_store_release(&sai->sai_task, NULL);
 		wake_up_process(task);
 	}
 	spin_unlock(&lli->lli_sa_lock);
@@ -1634,11 +1642,10 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry,
 		goto out;
 	}
 
-	if (test_bit(LL_SBI_AGL_ENABLED, ll_i2sbi(parent->d_inode)->ll_flags) &&
-	    agl)
+	if (test_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags) && agl)
 		ll_start_agl(parent, sai);
 
-	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_total);
+	atomic_inc(&sbi->ll_sa_total);
 	sai->sai_task = task;
 
 	wake_up_process(task);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
