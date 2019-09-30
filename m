From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:12 -0400
Subject: [lustre-devel] [PATCH 053/151] lustre: llite: increase whole-file
 readahead to RPC size
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-54-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Increase the default whole-file readahead limit to match the current
RPC size. That ensures that files smaller than the RPC size will be
read in a single round-trip instead of sending multiple smaller RPCs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7990
Lustre-commit: 627d0133d9d7 ("LU-7990 llite: increase whole-file readahead to RPC size")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/26955
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index beacaeb..07d1568 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -95,8 +95,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
 						    SBI_DEFAULT_READAHEAD_MAX);
 	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
-	sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
-					   SBI_DEFAULT_READAHEAD_WHOLE_MAX;
+	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 
 	ll_generate_random_uuid(uuid);
 	sprintf(sbi->ll_sb_uuid.uuid, "%pU", uuid);
@@ -269,6 +268,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	sbi->ll_md_exp->exp_connect_data = *data;
 
+	/* Don't change value if it was specified in the config log */
+	if (sbi->ll_ra_info.ra_max_read_ahead_whole_pages == -1)
+		sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
+			max_t(unsigned long, SBI_DEFAULT_READAHEAD_WHOLE_MAX,
+			      (data->ocd_brw_size >> PAGE_SHIFT));
+
 	err = obd_fid_init(sbi->ll_md_exp->exp_obd, sbi->ll_md_exp,
 			   LUSTRE_SEQ_METADATA);
 	if (err) {
-- 
1.8.3.1
