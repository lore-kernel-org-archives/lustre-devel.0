From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:13 -0400
Subject: [lustre-devel] [PATCH 04/12] staging: lustre: ldlm: check all
	errors during ldlm_debugfs_setup()
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Fix ignoring errors from ldebugfs_add_vars() function.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3885
Reviewed-on: http://review.whamcloud.com/8115
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 475fabb..e99c89c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -124,9 +124,15 @@ int ldlm_debugfs_setup(void)
 	}
 
 	rc = ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
+	if (rc) {
+		CERROR("LProcFS failed in ldlm-init\n");
+		goto err_svc;
+	}
 
 	return 0;
 
+err_svc:
+	ldebugfs_remove(&ldlm_svc_debugfs_dir);
 err_ns:
 	ldebugfs_remove(&ldlm_ns_debugfs_dir);
 err_type:
-- 
2.7.4
