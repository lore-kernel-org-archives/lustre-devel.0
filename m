Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0AE30ECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lG2z2Sz1y7N;
	Mon,  5 Sep 2022 18:55:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l65y5mz1y6k
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B986E100B001;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B065F58994; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:21 -0400
Message-Id: <1662429337-18737-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/24] lustre: statahead: add total hit/miss
 count stats
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

In this patch, it adds total hit/miss count stats for statahead.
These statistics are updated when the statahead thread terminated.

This patch also adds support to clear all statahead stats:
  $LCTL set_param llite.*.statahead_stats=0

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: b9167201a00e38ce8 ("LU-14139 statahead: add total hit/miss count stats")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/46309
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 ++
 fs/lustre/llite/llite_lib.c      |  2 ++
 fs/lustre/llite/lproc_llite.c    | 26 +++++++++++++++++++++++---
 fs/lustre/llite/statahead.c      |  3 +++
 4 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index e7f703a..227b944 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -749,6 +749,8 @@ struct ll_sb_info {
 						 * count
 						 */
 	atomic_t		ll_agl_total;	/* AGL thread started count */
+	atomic_t		ll_sa_hit_total;  /* total hit count */
+	atomic_t		ll_sa_miss_total; /* total miss count */
 
 	dev_t			ll_sdev_orig;	/* save s_dev before assign for
 						 * clustered nfs
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 0bffe5e..191a83c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -168,6 +168,8 @@ static struct ll_sb_info *ll_init_sbi(void)
 	atomic_set(&sbi->ll_sa_wrong, 0);
 	atomic_set(&sbi->ll_sa_running, 0);
 	atomic_set(&sbi->ll_agl_total, 0);
+	atomic_set(&sbi->ll_sa_hit_total, 0);
+	atomic_set(&sbi->ll_sa_miss_total, 0);
 	set_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags);
 	set_bit(LL_SBI_FAST_READ, sbi->ll_flags);
 	set_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 095b696..1391828 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -843,14 +843,34 @@ static int ll_statahead_stats_seq_show(struct seq_file *m, void *v)
 	seq_printf(m,
 		   "statahead total: %u\n"
 		   "statahead wrong: %u\n"
-		   "agl total: %u\n",
+		   "agl total: %u\n"
+		   "hit_total: %u\n"
+		   "miss_total: %u\n",
 		   atomic_read(&sbi->ll_sa_total),
 		   atomic_read(&sbi->ll_sa_wrong),
-		   atomic_read(&sbi->ll_agl_total));
+		   atomic_read(&sbi->ll_agl_total),
+		   atomic_read(&sbi->ll_sa_hit_total),
+		   atomic_read(&sbi->ll_sa_miss_total));
 	return 0;
 }
 
-LDEBUGFS_SEQ_FOPS_RO(ll_statahead_stats);
+static ssize_t ll_statahead_stats_seq_write(struct file *file,
+					    const char __user *buffer,
+					    size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+
+	atomic_set(&sbi->ll_sa_total, 0);
+	atomic_set(&sbi->ll_sa_wrong, 0);
+	atomic_set(&sbi->ll_agl_total, 0);
+	atomic_set(&sbi->ll_sa_hit_total, 0);
+	atomic_set(&sbi->ll_sa_miss_total, 0);
+
+	return count;
+}
+LDEBUGFS_SEQ_FOPS(ll_statahead_stats);
 
 static ssize_t lazystatfs_show(struct kobject *kobj,
 			       struct attribute *attr,
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 5662f44..1f1fafd 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1224,6 +1224,9 @@ static int ll_statahead_thread(void *arg)
 	spin_unlock(&lli->lli_sa_lock);
 	wake_up(&sai->sai_waitq);
 
+	atomic_add(sai->sai_hit, &sbi->ll_sa_hit_total);
+	atomic_add(sai->sai_miss, &sbi->ll_sa_miss_total);
+
 	ll_sai_put(sai);
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
