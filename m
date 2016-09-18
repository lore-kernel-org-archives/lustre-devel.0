From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:58 -0400
Subject: [lustre-devel] [PATCH 119/124] staging: lustre: lnet: potential
	deadlock in lnet
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-120-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Quentin Bouget <quentin.bouget.ocre@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Quentin Bouget <quentin.bouget.ocre@cea.fr>

Fixes potential deadlock in LNetMDAttach

Signed-off-by: Quentin Bouget <quentin.bouget.ocre@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8249
Reviewed-on: http://review.whamcloud.com/20676
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/lib-md.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index e0b2f16..eab53cd 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -292,11 +292,12 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 		return -ENOMEM;
 
 	rc = lnet_md_build(md, &umd, unlink);
+	if (rc)
+		goto out_free;
+
 	cpt = lnet_cpt_of_cookie(meh.cookie);
 
 	lnet_res_lock(cpt);
-	if (rc)
-		goto failed;
 
 	me = lnet_handle2me(&meh);
 	if (!me)
@@ -307,7 +308,7 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 		rc = lnet_md_link(md, umd.eq_handle, cpt);
 
 	if (rc)
-		goto failed;
+		goto out_unlock;
 
 	/*
 	 * attach this MD to portal of ME and check if it matches any
@@ -324,10 +325,10 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 
 	return 0;
 
- failed:
-	lnet_md_free(md);
-
+out_unlock:
 	lnet_res_unlock(cpt);
+out_free:
+	lnet_md_free(md);
 	return rc;
 }
 EXPORT_SYMBOL(LNetMDAttach);
@@ -370,24 +371,25 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 		return -ENOMEM;
 
 	rc = lnet_md_build(md, &umd, unlink);
+	if (rc)
+		goto out_free;
 
 	cpt = lnet_res_lock_current();
-	if (rc)
-		goto failed;
 
 	rc = lnet_md_link(md, umd.eq_handle, cpt);
 	if (rc)
-		goto failed;
+		goto out_unlock;
 
 	lnet_md2handle(handle, md);
 
 	lnet_res_unlock(cpt);
 	return 0;
 
- failed:
+out_unlock:
+	lnet_res_unlock(cpt);
+out_free:
 	lnet_md_free(md);
 
-	lnet_res_unlock(cpt);
 	return rc;
 }
 EXPORT_SYMBOL(LNetMDBind);
-- 
1.7.1
