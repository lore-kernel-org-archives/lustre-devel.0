From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:03 -0500
Subject: [lustre-devel] [PATCH 02/14] staging: lustre: llite: omit to update
	wire data
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

In ll_setattr_raw(), after op_data->op_attr has been copied, the attr
is updated and op_data->op_attr does not get updated afterward.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6813
Reviewed-on: http://review.whamcloud.com/16462
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 34422df..973eee6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1504,8 +1504,6 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		goto out;
 	}
 
-	op_data->op_attr = *attr;
-
 	if (!hsm_import && attr->ia_valid & ATTR_SIZE) {
 		/*
 		 * If we are changing file size, file content is
@@ -1516,6 +1514,8 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 		clear_bit(LLIF_DATA_MODIFIED, &lli->lli_flags);
 	}
 
+	op_data->op_attr = *attr;
+
 	rc = ll_md_setattr(dentry, op_data);
 	if (rc)
 		goto out;
-- 
1.8.3.1
