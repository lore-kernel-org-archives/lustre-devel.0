From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 24 Aug 2016 11:11:54 -0400
Subject: [lustre-devel] [PATCH v2 4/8] staging/lustre/llite: check return
	value for obd_set_info_async
In-Reply-To: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
References: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1472051518-745466-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Yang Sheng <yang.sheng@intel.com>

The return value is ignored in client_common_fill_super.
Restore to check it and error out.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-on: http://review.whamcloud.com/21125
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8360
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 72ff7c4..1ff788e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -498,11 +498,21 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
 				 KEY_CHECKSUM, sizeof(checksum), &checksum,
 				 NULL);
+	if (err) {
+		CERROR("%s: Set checksum failed: rc = %d\n",
+		       sbi->ll_dt_exp->exp_obd->obd_name, err);
+		goto out_root;
+	}
 	cl_sb_init(sb);
 
 	err = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CACHE_SET),
 				 KEY_CACHE_SET, sizeof(*sbi->ll_cache),
 				 sbi->ll_cache, NULL);
+	if (err) {
+		CERROR("%s: Set cache_set failed: rc = %d\n",
+		       sbi->ll_dt_exp->exp_obd->obd_name, err);
+		goto out_root;
+	}
 
 	sb->s_root = d_make_root(root);
 	if (!sb->s_root) {
-- 
2.7.4
