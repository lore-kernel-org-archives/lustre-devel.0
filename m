From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:46 -0500
Subject: [lustre-devel] [PATCH 298/622] lustre: rpc: support maximum 64MB
 I/O RPC
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-299-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

On newer systems, some block drivers allow max_hw_sector_kb to
be up to 65536KB (64MB) to the underlying storage. To maximize
driver efficiency, Lustre should also have bump up maximum I/O
RPC size to 64MB.
Clamp max_read_ahead_whold_mb not to exceed
max_read_ahead_per_file_mb

WC-bug-id: https://jira.whamcloud.com/browse/LU-11526
Lustre-commit: 1a9be0046b1f ("LU-11526 rpc: support maximum 64MB I/O RPC")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34042
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 2 +-
 fs/lustre/llite/llite_lib.c    | 7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 8d71559..f96265b 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -82,7 +82,7 @@
  * transfer via cl_max_pages_per_rpc to some non-power-of-two value.
  * NOTE: This is limited to 16 (=64GB RPCs) by IOOBJ_MAX_BRW_BITS.
  */
-#define PTLRPC_BULK_OPS_BITS	4
+#define PTLRPC_BULK_OPS_BITS	6
 #if PTLRPC_BULK_OPS_BITS > 16
 #error "More than 65536 BRW RPCs not allowed by IOOBJ_MAX_BRW_BITS."
 #endif
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d6293d1..e6ac16f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -281,10 +281,15 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	sbi->ll_md_exp->exp_connect_data = *data;
 
 	/* Don't change value if it was specified in the config log */
-	if (sbi->ll_ra_info.ra_max_read_ahead_whole_pages == -1)
+	if (sbi->ll_ra_info.ra_max_read_ahead_whole_pages == -1) {
 		sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
 			max_t(unsigned long, SBI_DEFAULT_READAHEAD_WHOLE_MAX,
 			      (data->ocd_brw_size >> PAGE_SHIFT));
+		if (sbi->ll_ra_info.ra_max_read_ahead_whole_pages >
+		    sbi->ll_ra_info.ra_max_pages_per_file)
+			sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
+				sbi->ll_ra_info.ra_max_pages_per_file;
+	}
 
 	err = obd_fid_init(sbi->ll_md_exp->exp_obd, sbi->ll_md_exp,
 			   LUSTRE_SEQ_METADATA);
-- 
1.8.3.1
