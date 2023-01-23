Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DB663C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:23:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Nf2Wypz22Q9;
	Mon, 23 Jan 2023 15:07:46 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15KK5rKYz21C2
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:53 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 60BD89EF;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2911A5898C; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:19 -0500
Message-Id: <1674514855-15399-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/42] lustre: ldebugfs: add histogram to
 stats counter
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

Add histogram to stats counter.
Example of enabling histogram for read/write_bytes in mdt/obdfilter
job stats.

Sample job_stats:
- job_id:          md5sum.0
snapshot_time   : 3143196.864165417 secs.nsecs
start_time      : 3143196.707206168 secs.nsecs
elapsed_time    : 0.156959249 secs.nsecs
  read_bytes:      { samples: 2, ..., hist: { 32K: 1, 1M: 1 } }
  write_bytes:     { samples: 1, ..., hist: { 1K: 1 } }

WC-bug-id: https://jira.whamcloud.com/browse/LU-16087
Lustre-commit: fde40ce32c91c804c ("LU-16087 lprocfs: add histogram to stats counter")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48278
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Shuichi Ihara <sihara@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h    |  7 +++++++
 fs/lustre/obdclass/lprocfs_counters.c | 13 +++++++++++++
 fs/lustre/obdclass/lprocfs_status.c   | 21 +++++++++++++++++++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 5cea77d1c246..f53125c96683 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -124,12 +124,16 @@ struct rename_stats {
  * squares (for multi-valued counter samples only). This allows
  * external computation of standard deviation, but involves a 64-bit
  * multiply per counter increment.
+ *
+ * LPROCFS_CNTR_HISTOGRAM indicates that the counter should track a
+ * exponential histogram.
  */
 
 enum lprocfs_counter_config {
 	LPROCFS_CNTR_EXTERNALLOCK	= 0x0001,
 	LPROCFS_CNTR_AVGMINMAX		= 0x0002,
 	LPROCFS_CNTR_STDDEV		= 0x0004,
+	LPROCFS_CNTR_HISTOGRAM		= 0x0008,
 
 	/* counter unit type */
 	LPROCFS_TYPE_REQS		= 0x0000, /* default if config = 0 */
@@ -147,6 +151,8 @@ enum lprocfs_counter_config {
 	LPROCFS_TYPE_BYTES_FULL		= LPROCFS_TYPE_BYTES |
 					  LPROCFS_CNTR_AVGMINMAX |
 					  LPROCFS_CNTR_STDDEV,
+	LPROCFS_TYPE_BYTES_FULL_HISTOGRAM	= LPROCFS_TYPE_BYTES_FULL |
+						  LPROCFS_CNTR_HISTOGRAM,
 };
 
 #define LC_MIN_INIT ((~(u64)0) >> 1)
@@ -155,6 +161,7 @@ struct lprocfs_counter_header {
 	enum lprocfs_counter_config	lc_config;
 	const char			*lc_name;   /* must be static */
 	const char			*lc_units;  /* must be static */
+	struct obd_histogram		*lc_hist;
 };
 
 struct lprocfs_counter {
diff --git a/fs/lustre/obdclass/lprocfs_counters.c b/fs/lustre/obdclass/lprocfs_counters.c
index 55cb12cc1399..4112dc355e94 100644
--- a/fs/lustre/obdclass/lprocfs_counters.c
+++ b/fs/lustre/obdclass/lprocfs_counters.c
@@ -48,6 +48,7 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 	struct lprocfs_counter_header *header;
 	int smp_id;
 	unsigned long flags = 0;
+	struct obd_histogram *hist;
 
 	if (!stats)
 		return;
@@ -87,6 +88,18 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 		if (amount > percpu_cntr->lc_max)
 			percpu_cntr->lc_max = amount;
 	}
+	/* no counter in interrupt has historgram for now */
+	hist = stats->ls_cnt_header[idx].lc_hist;
+	if (hist != NULL) {
+		unsigned int val = 0;
+
+		if (likely(amount != 0))
+			val = min(fls(amount - 1), OBD_HIST_MAX - 1);
+		spin_lock(&hist->oh_lock);
+		hist->oh_buckets[val]++;
+		spin_unlock(&hist->oh_lock);
+	}
+
 	lprocfs_stats_unlock(stats, LPROCFS_GET_SMP_ID, &flags);
 }
 EXPORT_SYMBOL(lprocfs_counter_add);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 64d7cc48cd0c..01b8132087d6 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1311,13 +1311,20 @@ EXPORT_SYMBOL(lprocfs_stats_collector);
 void lprocfs_clear_stats(struct lprocfs_stats *stats)
 {
 	struct lprocfs_counter *percpu_cntr;
-	int i;
-	int j;
+	int i, j;
 	unsigned int num_entry;
 	unsigned long flags = 0;
 
 	num_entry = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 
+	/* clear histogram if exists */
+	for (j = 0; j < stats->ls_num; j++) {
+		struct obd_histogram *hist = stats->ls_cnt_header[j].lc_hist;
+
+		if (hist != NULL)
+			lprocfs_oh_clear(hist);
+	}
+
 	for (i = 0; i < num_entry; i++) {
 		if (!stats->ls_percpu[i])
 			continue;
@@ -1497,6 +1504,16 @@ void lprocfs_counter_init_units(struct lprocfs_stats *stats, int index,
 	header->lc_name = name;
 	header->lc_units = units;
 
+	if (config & LPROCFS_CNTR_HISTOGRAM) {
+		stats->ls_cnt_header[index].lc_hist =
+			kzalloc(sizeof(*stats->ls_cnt_header[index].lc_hist),
+				GFP_NOFS);
+		if (stats->ls_cnt_header[index].lc_hist == NULL)
+			CERROR("LprocFS: Failed to allocate histogram:[%d]%s/%s\n",
+			       index, name, units);
+		else
+			spin_lock_init(&stats->ls_cnt_header[index].lc_hist->oh_lock);
+	}
 	num_cpu = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 	for (i = 0; i < num_cpu; ++i) {
 		if (!stats->ls_percpu[i])
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
