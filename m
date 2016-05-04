From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:55 -0400
Subject: [lustre-devel] [PATCH 4/9] staging: lustre: mdt: extra checking for
	getattr RPC.
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Check whether getattr RPC can hold layout MD(RMF_MDT_MD),
in case the client sends some invalid RPC, which can
cause panic on MDT.

Client will retrieve cl_max_md_size/cl_default_md_size
from MDS during mount process, so it will initialize
cl_max_md_size/cl_default_md_size before sending getattr
to MDS.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4222
Reviewed-on: http://review.whamcloud.com/8599
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 64be2c1..44dd3f3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -445,7 +445,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	/* make root inode
 	 * XXX: move this to after cbd setup?
 	 */
-	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS;
+	valid = OBD_MD_FLGETATTR | OBD_MD_FLBLOCKS | OBD_MD_FLMODEASIZE;
 	if (sbi->ll_flags & LL_SBI_RMT_CLIENT)
 		valid |= OBD_MD_FLRMTPERM;
 	else if (sbi->ll_flags & LL_SBI_ACL)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 46e3a7506..86b7445 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -142,9 +142,8 @@ static int mdc_getattr_common(struct obd_export *exp,
 
 	CDEBUG(D_NET, "mode: %o\n", body->mode);
 
+	mdc_update_max_ea_from_body(exp, body);
 	if (body->eadatasize != 0) {
-		mdc_update_max_ea_from_body(exp, body);
-
 		eadata = req_capsule_server_sized_get(pill, &RMF_MDT_MD,
 						      body->eadatasize);
 		if (!eadata)
-- 
2.7.4
