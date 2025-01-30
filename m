Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D848DC0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:48:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLkf2KSBz22Lk;
	Thu, 30 Jan 2025 06:19:38 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLZy3YTlz1y22
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:58 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1E08318236C;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1A3AF106BE17; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:05 -0500
Message-ID: <20250130141115.950749-16-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 15/25] lustre: statahead: add stats for batch
 RPC requests
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

This patch adds stats for batch PtlRPC request. It can show the
statistical information such as how many subreqs in a batch RPC.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: a20f25d24b5f0ce7b ("LU-14139 statahead: add stats for batch RPC requests")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/40943
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h   |  3 +++
 fs/lustre/ldlm/ldlm_lib.c |  1 +
 fs/lustre/mdc/lproc_mdc.c | 44 +++++++++++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/batch.c  |  7 ++++++-
 4 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 4d65775ab4b1..174372001b23 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -277,6 +277,9 @@ struct client_obd {
 	struct obd_histogram    cl_write_page_hist;
 	struct obd_histogram    cl_read_offset_hist;
 	struct obd_histogram    cl_write_offset_hist;
+	ktime_t			cl_batch_stats_init;
+	struct obd_histogram	cl_batch_rpc_hist;
+
 
 	/* LRU for osc caching pages */
 	struct cl_client_cache	*cl_cache;
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 4f9cf5f5c388..6a03ca9e2c06 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -367,6 +367,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	spin_lock_init(&cli->cl_write_page_hist.oh_lock);
 	spin_lock_init(&cli->cl_read_offset_hist.oh_lock);
 	spin_lock_init(&cli->cl_write_offset_hist.oh_lock);
+	spin_lock_init(&cli->cl_batch_rpc_hist.oh_lock);
 
 	/* lru for osc. */
 	INIT_LIST_HEAD(&cli->cl_lru_osc);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index fa799c525f46..d8dded8ed8a6 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -509,6 +509,48 @@ static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
 }
 LDEBUGFS_SEQ_FOPS(mdc_rpc_stats);
 
+static ssize_t mdc_batch_stats_seq_write(struct file *file,
+					 const char __user *buf,
+					 size_t len, loff_t *off)
+{
+	struct seq_file *seq = file->private_data;
+	struct obd_device *obd = seq->private;
+	struct client_obd *cli = &obd->u.cli;
+
+	lprocfs_oh_clear(&cli->cl_batch_rpc_hist);
+	cli->cl_batch_stats_init = ktime_get_real();
+
+	return len;
+}
+
+static int mdc_batch_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct obd_device *obd = seq->private;
+	struct client_obd *cli = &obd->u.cli;
+	unsigned long tot;
+	unsigned long cum;
+	int i;
+
+	lprocfs_stats_header(seq, ktime_get_real(), cli->cl_batch_stats_init,
+			     25, ":", true, "");
+	seq_puts(seq, "subreqs per batch   batches   %% cum %%\n");
+	tot = lprocfs_oh_sum(&cli->cl_batch_rpc_hist);
+	cum = 0;
+
+	for (i = 0; i < OBD_HIST_MAX; i++) {
+		unsigned long cnt = cli->cl_batch_rpc_hist.oh_buckets[i];
+
+		cum += cnt;
+		seq_printf(seq, "%d:\t\t%10lu %3u %3u\n",
+			   1 << i, cnt, pct(cnt, tot), pct(cum, tot));
+		if (cum == tot)
+			break;
+	}
+
+	return 0;
+}
+LDEBUGFS_SEQ_FOPS(mdc_batch_stats);
+
 static int mdc_stats_seq_show(struct seq_file *seq, void *v)
 {
 	struct obd_device *obd = seq->private;
@@ -624,6 +666,8 @@ static struct ldebugfs_vars lprocfs_mdc_obd_vars[] = {
 	  .fops	=	&mdc_pinger_recov_fops		},
 	{ .name =	"rpc_stats",
 	  .fops =	&mdc_rpc_stats_fops		},
+	{ .name =	"batch_stats",
+	  .fops =	&mdc_batch_stats_fops		},
 	{ .name	=	"unstable_stats",
 	  .fops	=	&mdc_unstable_stats_fops	},
 	{ .name	=	"mdc_stats",
diff --git a/fs/lustre/ptlrpc/batch.c b/fs/lustre/ptlrpc/batch.c
index 76eb4cf0ac4f..75a6bc21b869 100644
--- a/fs/lustre/ptlrpc/batch.c
+++ b/fs/lustre/ptlrpc/batch.c
@@ -39,6 +39,7 @@
 #include <linux/module.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <obd.h>
+#include <obd_class.h>
 
 #define OUT_UPDATE_REPLY_SIZE          4096
 
@@ -403,14 +404,16 @@ static int batch_update_interpret(const struct lu_env *env,
 static int batch_send_update_req(const struct lu_env *env,
 				 struct batch_update_head *head)
 {
-	struct lu_batch *bh;
+	struct obd_device *obd;
 	struct ptlrpc_request *req = NULL;
 	struct batch_update_args *aa;
+	struct lu_batch *bh;
 	int rc;
 
 	if (!head)
 		return 0;
 
+	obd = class_exp2obd(head->buh_exp);
 	bh = head->buh_batch;
 	rc = batch_prep_update_req(head, &req);
 	if (rc) {
@@ -447,6 +450,8 @@ static int batch_send_update_req(const struct lu_env *env,
 	if (req)
 		ptlrpc_req_finished(req);
 
+	lprocfs_oh_tally_log2(&obd->u.cli.cl_batch_rpc_hist,
+			      head->buh_update_count);
 	return rc;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
