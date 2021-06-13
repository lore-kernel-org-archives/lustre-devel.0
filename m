Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59C36C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D4F17611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4F17611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D035221EB73;
	Sun, 13 Jun 2021 16:11:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 37D1921D4A8
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BF14A100B034;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B57FE9C303; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:18 -0400
Message-Id: <1623625897-17706-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/27] lustre: rename tgt_pool_* functions.
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Functions starting with tgt_* represents code for target handling
used by Lustre servers. Now that the pool functions are used by
both clients and servers rename it to lu_tgt_* to mirror how
lu_tgt_desc_* is used since both represents remote server targets.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14291
Lustre-commit: 7f3b06a0ab527c3a ("LU-14291 lustre: rename tgt_pool_* functions.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/43624
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
---
 fs/lustre/include/lu_object.h    | 12 ++++++------
 fs/lustre/lov/lov_obd.c          | 12 ++++++------
 fs/lustre/lov/lov_pool.c         | 10 +++++-----
 fs/lustre/obdclass/lu_tgt_pool.c | 28 ++++++++++++++--------------
 4 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index b1d7577..bbc4533 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1413,12 +1413,12 @@ struct lu_tgt_pool {
 	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
 };
 
-int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
-int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
-int tgt_pool_remove(struct lu_tgt_pool *op, u32 idx);
-int tgt_pool_free(struct lu_tgt_pool *op);
-int tgt_check_index(int idx, struct lu_tgt_pool *osts);
-int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
+int lu_tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
+int lu_tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
+int lu_tgt_pool_remove(struct lu_tgt_pool *op, u32 idx);
+int lu_tgt_pool_free(struct lu_tgt_pool *op);
+int lu_tgt_check_index(int idx, struct lu_tgt_pool *osts);
+int lu_tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
 
 /* bitflags used in rr / qos allocation */
 enum lq_flag {
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 42a137d..61159fd 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -95,7 +95,7 @@ void lov_tgts_putref(struct obd_device *obd)
 			 * being the maximum tgt index for computing the
 			 * mds_max_easize. So we can't shrink it.
 			 */
-			tgt_pool_remove(&lov->lov_packed, i);
+			lu_tgt_pool_remove(&lov->lov_packed, i);
 			lov->lov_tgts[i] = NULL;
 			lov->lov_death_row--;
 		}
@@ -544,7 +544,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		return -ENOMEM;
 	}
 
-	rc = tgt_pool_add(&lov->lov_packed, index, lov->lov_tgt_size);
+	rc = lu_tgt_pool_add(&lov->lov_packed, index, lov->lov_tgt_size);
 	if (rc) {
 		mutex_unlock(&lov->lov_lock);
 		kfree(tgt);
@@ -763,7 +763,7 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		goto out_hash;
 
-	rc = tgt_pool_init(&lov->lov_packed, 0);
+	rc = lu_tgt_pool_init(&lov->lov_packed, 0);
 	if (rc)
 		goto out_pool;
 
@@ -777,7 +777,7 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return 0;
 
 out_tunables:
-	tgt_pool_free(&lov->lov_packed);
+	lu_tgt_pool_free(&lov->lov_packed);
 out_pool:
 	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
 out_hash:
@@ -804,7 +804,7 @@ static int lov_cleanup(struct obd_device *obd)
 		lov_pool_del(obd, pool->pool_name);
 	}
 	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
-	tgt_pool_free(&lov->lov_packed);
+	lu_tgt_pool_free(&lov->lov_packed);
 
 	lprocfs_obd_cleanup(obd);
 	if (lov->lov_tgts) {
@@ -1254,7 +1254,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 			continue;
 
 		if (pool &&
-		    tgt_check_index(tgt->ltd_index, &pool->pool_obds))
+		    lu_tgt_check_index(tgt->ltd_index, &pool->pool_obds))
 			continue;
 
 		if (!tgt->ltd_active || tgt->ltd_reap) {
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index d01c475..25e980f 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -82,7 +82,7 @@ void lov_pool_putref(struct pool_desc *pool)
 	CDEBUG(D_INFO, "pool %p\n", pool);
 	if (atomic_dec_and_test(&pool->pool_refcount)) {
 		LASSERT(list_empty(&pool->pool_list));
-		tgt_pool_free(&pool->pool_obds);
+		lu_tgt_pool_free(&pool->pool_obds);
 		kfree_rcu(pool, rcu);
 	}
 }
@@ -268,7 +268,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	 * up to deletion
 	 */
 	atomic_set(&new_pool->pool_refcount, 1);
-	rc = tgt_pool_init(&new_pool->pool_obds, 0);
+	rc = lu_tgt_pool_init(&new_pool->pool_obds, 0);
 	if (rc)
 		goto out_err;
 
@@ -310,7 +310,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	lov->lov_pool_count--;
 	spin_unlock(&obd->obd_dev_lock);
 	debugfs_remove_recursive(new_pool->pool_debugfs_entry);
-	tgt_pool_free(&new_pool->pool_obds);
+	lu_tgt_pool_free(&new_pool->pool_obds);
 	kfree(new_pool);
 
 	return rc;
@@ -401,7 +401,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 		goto out;
 	}
 
-	rc = tgt_pool_add(&pool->pool_obds, lov_idx, lov->lov_tgt_size);
+	rc = lu_tgt_pool_add(&pool->pool_obds, lov_idx, lov->lov_tgt_size);
 	if (rc)
 		goto out;
 
@@ -453,7 +453,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 		goto out;
 	}
 
-	tgt_pool_remove(&pool->pool_obds, lov_idx);
+	lu_tgt_pool_remove(&pool->pool_obds, lov_idx);
 
 	CDEBUG(D_CONFIG, "%s removed from " LOV_POOLNAMEF "\n", ostname,
 	       poolname);
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
index a8e1028..8f52fb4 100644
--- a/fs/lustre/obdclass/lu_tgt_pool.c
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -29,7 +29,7 @@
  * This file is part of Lustre, http://www.lustre.org/
  */
 /*
- * lustre/target/tgt_pool.c
+ * lustre/obdclass/lu_tgt_pool.c
  *
  * This file handles creation, lookup, and removal of pools themselves, as
  * well as adding and removing targets to pools.
@@ -60,7 +60,7 @@
  *		negative error number on failure
  */
 #define POOL_INIT_COUNT 2
-int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count)
+int lu_tgt_pool_init(struct lu_tgt_pool *op, unsigned int count)
 {
 	if (count == 0)
 		count = POOL_INIT_COUNT;
@@ -77,7 +77,7 @@ int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count)
 
 	return 0;
 }
-EXPORT_SYMBOL(tgt_pool_init);
+EXPORT_SYMBOL(lu_tgt_pool_init);
 
 /**
  * Increase the op_array size to hold more targets in this pool.
@@ -92,7 +92,7 @@ int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count)
  * Return:	0 on success
  *		negative error number on failure.
  */
-int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
+int lu_tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
 {
 	u32 *new;
 	u32 new_size;
@@ -116,7 +116,7 @@ int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
 
 	return 0;
 }
-EXPORT_SYMBOL(tgt_pool_extend);
+EXPORT_SYMBOL(lu_tgt_pool_extend);
 
 /**
  * Add a new target to an existing pool.
@@ -131,14 +131,14 @@ int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
  * Return:	0 if target could be added to the pool
  *		negative error if target \a idx was not added
  */
-int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
+int lu_tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
 {
 	unsigned int i;
 	int rc = 0;
 
 	down_write(&op->op_rw_sem);
 
-	rc = tgt_pool_extend(op, min_count);
+	rc = lu_tgt_pool_extend(op, min_count);
 	if (rc)
 		goto out;
 
@@ -156,7 +156,7 @@ int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
 	up_write(&op->op_rw_sem);
 	return rc;
 }
-EXPORT_SYMBOL(tgt_pool_add);
+EXPORT_SYMBOL(lu_tgt_pool_add);
 
 /**
  * Remove an existing pool from the system.
@@ -172,7 +172,7 @@ int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
  * Return:	0 on success
  *		negative error number on failure
  */
-int tgt_pool_remove(struct lu_tgt_pool *op, u32 idx)
+int lu_tgt_pool_remove(struct lu_tgt_pool *op, u32 idx)
 {
 	unsigned int i;
 
@@ -192,9 +192,9 @@ int tgt_pool_remove(struct lu_tgt_pool *op, u32 idx)
 	up_write(&op->op_rw_sem);
 	return -EINVAL;
 }
-EXPORT_SYMBOL(tgt_pool_remove);
+EXPORT_SYMBOL(lu_tgt_pool_remove);
 
-int tgt_check_index(int idx, struct lu_tgt_pool *osts)
+int lu_tgt_check_index(int idx, struct lu_tgt_pool *osts)
 {
 	int rc = 0, i;
 
@@ -208,7 +208,7 @@ int tgt_check_index(int idx, struct lu_tgt_pool *osts)
 	up_read(&osts->op_rw_sem);
 	return rc;
 }
-EXPORT_SYMBOL(tgt_check_index);
+EXPORT_SYMBOL(lu_tgt_check_index);
 
 /**
  * Free the pool after it was emptied and removed from /proc.
@@ -221,7 +221,7 @@ int tgt_check_index(int idx, struct lu_tgt_pool *osts)
  *
  * Return:	0 on success or if pool was already freed
  */
-int tgt_pool_free(struct lu_tgt_pool *op)
+int lu_tgt_pool_free(struct lu_tgt_pool *op)
 {
 	if (op->op_size == 0)
 		return 0;
@@ -236,4 +236,4 @@ int tgt_pool_free(struct lu_tgt_pool *op)
 	up_write(&op->op_rw_sem);
 	return 0;
 }
-EXPORT_SYMBOL(tgt_pool_free);
+EXPORT_SYMBOL(lu_tgt_pool_free);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
