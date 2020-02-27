From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:58 -0500
Subject: [lustre-devel] [PATCH 010/622] lustre: llite: increase whole-file
 readahead to RPC size
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Increase the default whole-file readahead limit to match the current
RPC size.  That ensures that files smaller than the RPC size will be
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
 fs/lustre/llite/llite_lib.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index aaa8ad2..12aafe0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -465,6 +465,12 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	sbi->ll_dt_exp->exp_connect_data = *data;
 
+	/* Don't change value if it was specified in the config log */
+	if (sbi->ll_ra_info.ra_max_read_ahead_whole_pages == -1)
+		sbi->ll_ra_info.ra_max_read_ahead_whole_pages =
+			max_t(unsigned long, SBI_DEFAULT_READAHEAD_WHOLE_MAX,
+			      (data->ocd_brw_size >> PAGE_SHIFT));
+
 	err = obd_fid_init(sbi->ll_dt_exp->exp_obd, sbi->ll_dt_exp,
 			   LUSTRE_SEQ_METADATA);
 	if (err) {
-- 
1.8.3.1
