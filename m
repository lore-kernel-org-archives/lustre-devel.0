Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6497EC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:09:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2240421EBED;
	Sun, 12 Dec 2021 07:08:32 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B35F821F46A
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C546010084EB;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B809DE0813; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:59 -0500
Message-Id: <1639321683-22909-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/12] lustre: obdclass: cosmetic changes in
 pool handling
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Sergey Cheremencev <sergey.cheremencev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sergey Cheremencev <sergey.cheremencev@hpe.com>

cosmetic changes in pool handling:
- make tgt_pool_free void
- set default rc value in lu_tgt_check_index.

HPE-bug-id: LUS-9547
WC-bug-id: https://jira.whamcloud.com/browse/LU-15110
Lustre-commit: d01cae3ec8758fc27 ("LU-15110 quota: cosmetic changes in PQ")
Signed-off-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-on: https://review.whamcloud.com/45258
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h    |  2 +-
 fs/lustre/obdclass/lu_tgt_pool.c | 15 +++++++--------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 146398a..3fb40c6 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1423,7 +1423,7 @@ struct lu_tgt_pool {
 int lu_tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
 int lu_tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
 int lu_tgt_pool_remove(struct lu_tgt_pool *op, u32 idx);
-int lu_tgt_pool_free(struct lu_tgt_pool *op);
+void lu_tgt_pool_free(struct lu_tgt_pool *op);
 int lu_tgt_check_index(int idx, struct lu_tgt_pool *osts);
 int lu_tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
 
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
index 17bae54..38ab83d 100644
--- a/fs/lustre/obdclass/lu_tgt_pool.c
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -197,14 +197,15 @@ int lu_tgt_pool_remove(struct lu_tgt_pool *op, u32 idx)
 
 int lu_tgt_check_index(int idx, struct lu_tgt_pool *osts)
 {
-	int rc = 0, i;
+	int i, rc = -ENOENT;
 
 	down_read(&osts->op_rw_sem);
 	for (i = 0; i < osts->op_count; i++) {
-		if (osts->op_array[i] == idx)
+		if (osts->op_array[i] == idx) {
+			rc = 0;
 			goto out;
+		}
 	}
-	rc = -ENOENT;
 out:
 	up_read(&osts->op_rw_sem);
 	return rc;
@@ -219,13 +220,11 @@ int lu_tgt_check_index(int idx, struct lu_tgt_pool *osts)
  * deleted from memory.
  *
  * @op		pool to be freed.
- *
- * Return:	0 on success or if pool was already freed
  */
-int lu_tgt_pool_free(struct lu_tgt_pool *op)
+void lu_tgt_pool_free(struct lu_tgt_pool *op)
 {
 	if (op->op_size == 0)
-		return 0;
+		return;
 
 	down_write(&op->op_rw_sem);
 
@@ -235,6 +234,6 @@ int lu_tgt_pool_free(struct lu_tgt_pool *op)
 	op->op_size = 0;
 
 	up_write(&op->op_rw_sem);
-	return 0;
+	return;
 }
 EXPORT_SYMBOL(lu_tgt_pool_free);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
