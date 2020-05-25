From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:51 -0400
Subject: [lustre-devel] [PATCH 14/45] lustre: Remove inappropriate uses of
 BIT() macro.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The BIT() macro exists for identifying a specific bit in a word when
it is being used as a bitmap (or mask for set of flags etc).
While it uses "1 << ...." it is not a general replacement for that
construct and should not be used to simply to raise '2' to some power.

Varous places in lustre and libcfs use BIT() when a size, rather than
a BIT, are required.  Convert these to explicitly use "1 << exponent".

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 423ad81446973 ("LU-6142 lustre: Remove inappropriate uses of BIT() macro.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38373
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_resource.c |  4 ++--
 fs/lustre/llite/lproc_llite.c  |  4 ++--
 fs/lustre/obdclass/class_obd.c | 12 +++++++-----
 net/lnet/libcfs/module.c       | 17 ++++++++---------
 4 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 9b24be7..0a3d861 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -613,8 +613,8 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_bucket_bits = ldlm_ns_hash_defs[ns_type].nsd_all_bits -
 			     ldlm_ns_hash_defs[ns_type].nsd_bkt_bits;
 
-	ns->ns_rs_buckets = kvmalloc(BIT(ns->ns_bucket_bits) *
-				     sizeof(ns->ns_rs_buckets[0]),
+	ns->ns_rs_buckets = kvzalloc((1 << ns->ns_bucket_bits) *
+				     sizeof(*ns->ns_rs_buckets),
 				     GFP_KERNEL);
 	if (!ns->ns_rs_buckets)
 		goto out_hash;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 5b10ed0..36cc8bc 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1780,7 +1780,7 @@ static void ll_display_extents_info(struct ll_rw_extents_info *io_extents,
 		w = pp_info->pp_w_hist.oh_buckets[i];
 		read_cum += r;
 		write_cum += w;
-		end = BIT(i + LL_HIST_START - units);
+		end = 1 << (i + LL_HIST_START - units);
 		seq_printf(seq,
 			   "%4lu%c - %4lu%c%c: %14lu %4u %4u  | %14lu %4u %4u\n",
 			   start, *unitp, end, *unitp,
@@ -1958,7 +1958,7 @@ void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		lprocfs_oh_clear(&io_extents->pp_extents[cur].pp_w_hist);
 	}
 
-	for (i = 0; (count >= BIT(LL_HIST_START + i)) &&
+	for (i = 0; (count >= 1 << (LL_HIST_START + i)) &&
 	     (i < (LL_HIST_MAX - 1)); i++)
 		;
 	if (rw == 0) {
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 038ee62..76664bf 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -113,27 +113,29 @@ static int class_resolve_dev_name(u32 len, const char *name)
 
 static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 {
-	if (data->ioc_len > BIT(30)) {
+	const int maxlen = 1 << 30;
+
+	if (data->ioc_len > maxlen) {
 		CERROR("OBD ioctl: ioc_len larger than 1<<30\n");
 		return 1;
 	}
 
-	if (data->ioc_inllen1 > BIT(30)) {
+	if (data->ioc_inllen1 > maxlen) {
 		CERROR("OBD ioctl: ioc_inllen1 larger than 1<<30\n");
 		return 1;
 	}
 
-	if (data->ioc_inllen2 > BIT(30)) {
+	if (data->ioc_inllen2 > maxlen) {
 		CERROR("OBD ioctl: ioc_inllen2 larger than 1<<30\n");
 		return 1;
 	}
 
-	if (data->ioc_inllen3 > BIT(30)) {
+	if (data->ioc_inllen3 > maxlen) {
 		CERROR("OBD ioctl: ioc_inllen3 larger than 1<<30\n");
 		return 1;
 	}
 
-	if (data->ioc_inllen4 > BIT(30)) {
+	if (data->ioc_inllen4 > maxlen) {
 		CERROR("OBD ioctl: ioc_inllen4 larger than 1<<30\n");
 		return 1;
 	}
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index fc5bc25..ad6935c 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -80,18 +80,17 @@ static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 
 static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 {
-	if (data->ioc_hdr.ioc_len > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
+	const int maxlen = 1 << 30;
+
+	if (data->ioc_hdr.ioc_len > maxlen)
 		return true;
-	}
-	if (data->ioc_inllen1 > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen1 larger than 1<<30\n");
+
+	if (data->ioc_inllen1 > maxlen)
 		return true;
-	}
-	if (data->ioc_inllen2 > BIT(30)) {
-		CERROR("LIBCFS ioctl: ioc_inllen2 larger than 1<<30\n");
+
+	if (data->ioc_inllen2 > maxlen)
 		return true;
-	}
+
 	if (data->ioc_inlbuf1 && !data->ioc_inllen1) {
 		CERROR("LIBCFS ioctl: inlbuf1 pointer but 0 length\n");
 		return true;
-- 
1.8.3.1
