Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E4CDC433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 56A2161249
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56A2161249
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 016BA21FB1D;
	Wed, 14 Apr 2021 21:03:34 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BF57C32F64A
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A1614100F360;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9F5C491890; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:23 -0400
Message-Id: <1618459361-17909-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/49] lustre: use tgt_pool for lov layer
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
Cc: Sergey Cheremencev <c17829@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

New general code was created for server target pool handling. We
can use this new code with the lov layer. Place this tgt_pool.c
in the obdclass instead of having a special target directory just
to build this code for the client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14291
Lustre-commit: 01d23cc780c6c7f ("LU-14291 build: use tgt_pool for lov layer")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/39683
WC-bug-id: https://jira.whamcloud.com/browse/LU-11023
Lustre-commit: 09f9fb3211cd998 ("LU-11023 quota: quota pools for OSTs")
Signed-off-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/lov/lov_internal.h     |   7 --
 fs/lustre/lov/lov_obd.c          |  10 +-
 fs/lustre/lov/lov_pool.c         | 114 +-----------------
 fs/lustre/obdclass/Makefile      |   4 +-
 fs/lustre/obdclass/lu_tgt_pool.c | 241 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 253 insertions(+), 123 deletions(-)
 create mode 100644 fs/lustre/obdclass/lu_tgt_pool.c

diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 81adce4..2e1e2dd 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -333,13 +333,6 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
 
 #define LOV_MDC_TGT_MAX 256
 
-/* lu_tgt_pool methods */
-int lov_ost_pool_init(struct lu_tgt_pool *op, unsigned int count);
-int lov_ost_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
-int lov_ost_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
-int lov_ost_pool_remove(struct lu_tgt_pool *op, u32 idx);
-int lov_ost_pool_free(struct lu_tgt_pool *op);
-
 /* high level pool methods */
 int lov_pool_new(struct obd_device *obd, char *poolname);
 int lov_pool_del(struct obd_device *obd, char *poolname);
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 2939d66..4f574ad 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -96,7 +96,7 @@ void lov_tgts_putref(struct obd_device *obd)
 			 * being the maximum tgt index for computing the
 			 * mds_max_easize. So we can't shrink it.
 			 */
-			lov_ost_pool_remove(&lov->lov_packed, i);
+			tgt_pool_remove(&lov->lov_packed, i);
 			lov->lov_tgts[i] = NULL;
 			lov->lov_death_row--;
 		}
@@ -545,7 +545,7 @@ static int lov_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
 		return -ENOMEM;
 	}
 
-	rc = lov_ost_pool_add(&lov->lov_packed, index, lov->lov_tgt_size);
+	rc = tgt_pool_add(&lov->lov_packed, index, lov->lov_tgt_size);
 	if (rc) {
 		mutex_unlock(&lov->lov_lock);
 		kfree(tgt);
@@ -764,7 +764,7 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (rc)
 		goto out_hash;
 
-	rc = lov_ost_pool_init(&lov->lov_packed, 0);
+	rc = tgt_pool_init(&lov->lov_packed, 0);
 	if (rc)
 		goto out_pool;
 
@@ -778,7 +778,7 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	return 0;
 
 out_tunables:
-	lov_ost_pool_free(&lov->lov_packed);
+	tgt_pool_free(&lov->lov_packed);
 out_pool:
 	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
 out_hash:
@@ -805,7 +805,7 @@ static int lov_cleanup(struct obd_device *obd)
 		lov_pool_del(obd, pool->pool_name);
 	}
 	lov_pool_hash_destroy(&lov->lov_pools_hash_body);
-	lov_ost_pool_free(&lov->lov_packed);
+	tgt_pool_free(&lov->lov_packed);
 
 	lprocfs_obd_cleanup(obd);
 	if (lov->lov_tgts) {
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index f8f14f9..2617974 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -83,7 +83,7 @@ void lov_pool_putref(struct pool_desc *pool)
 	CDEBUG(D_INFO, "pool %p\n", pool);
 	if (atomic_dec_and_test(&pool->pool_refcount)) {
 		LASSERT(list_empty(&pool->pool_list));
-		lov_ost_pool_free(&pool->pool_obds);
+		tgt_pool_free(&pool->pool_obds);
 		kfree_rcu(pool, rcu);
 	}
 }
@@ -230,110 +230,6 @@ static int pool_proc_open(struct inode *inode, struct file *file)
 	.release	= seq_release,
 };
 
-#define LOV_POOL_INIT_COUNT 2
-int lov_ost_pool_init(struct lu_tgt_pool *op, unsigned int count)
-{
-	if (count == 0)
-		count = LOV_POOL_INIT_COUNT;
-	op->op_array = NULL;
-	op->op_count = 0;
-	init_rwsem(&op->op_rw_sem);
-	op->op_size = count * sizeof(op->op_array[0]);
-	op->op_array = kcalloc(count, sizeof(op->op_array[0]),
-			       GFP_KERNEL);
-	if (!op->op_array) {
-		op->op_size = 0;
-		return -ENOMEM;
-	}
-	return 0;
-}
-
-/* Caller must hold write op_rwlock */
-int lov_ost_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
-{
-	int new_count;
-	u32 *new;
-
-	LASSERT(min_count != 0);
-
-	if (op->op_count * sizeof(op->op_array[0]) < op->op_size)
-		return 0;
-
-	new_count = max_t(u32, min_count,
-			  2 * op->op_size / sizeof(op->op_array[0]));
-	new = kcalloc(new_count, sizeof(op->op_array[0]), GFP_KERNEL);
-	if (!new)
-		return -ENOMEM;
-
-	/* copy old array to new one */
-	memcpy(new, op->op_array, op->op_size);
-	kfree(op->op_array);
-	op->op_array = new;
-	op->op_size = new_count * sizeof(op->op_array[0]);
-	return 0;
-}
-
-int lov_ost_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
-{
-	int rc = 0, i;
-
-	down_write(&op->op_rw_sem);
-
-	rc = lov_ost_pool_extend(op, min_count);
-	if (rc)
-		goto out;
-
-	/* search ost in pool array */
-	for (i = 0; i < op->op_count; i++) {
-		if (op->op_array[i] == idx) {
-			rc = -EEXIST;
-			goto out;
-		}
-	}
-	/* ost not found we add it */
-	op->op_array[op->op_count] = idx;
-	op->op_count++;
-out:
-	up_write(&op->op_rw_sem);
-	return rc;
-}
-
-int lov_ost_pool_remove(struct lu_tgt_pool *op, u32 idx)
-{
-	int i;
-
-	down_write(&op->op_rw_sem);
-
-	for (i = 0; i < op->op_count; i++) {
-		if (op->op_array[i] == idx) {
-			memmove(&op->op_array[i], &op->op_array[i + 1],
-				(op->op_count - i - 1) * sizeof(op->op_array[0]));
-			op->op_count--;
-			up_write(&op->op_rw_sem);
-			return 0;
-		}
-	}
-
-	up_write(&op->op_rw_sem);
-	return -EINVAL;
-}
-
-int lov_ost_pool_free(struct lu_tgt_pool *op)
-{
-	if (op->op_size == 0)
-		return 0;
-
-	down_write(&op->op_rw_sem);
-
-	kfree(op->op_array);
-	op->op_array = NULL;
-	op->op_count = 0;
-	op->op_size = 0;
-
-	up_write(&op->op_rw_sem);
-	return 0;
-}
-
 static void
 pools_hash_exit(void *vpool, void *data)
 {
@@ -373,7 +269,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	 * up to deletion
 	 */
 	atomic_set(&new_pool->pool_refcount, 1);
-	rc = lov_ost_pool_init(&new_pool->pool_obds, 0);
+	rc = tgt_pool_init(&new_pool->pool_obds, 0);
 	if (rc)
 		goto out_err;
 
@@ -415,7 +311,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	lov->lov_pool_count--;
 	spin_unlock(&obd->obd_dev_lock);
 	debugfs_remove_recursive(new_pool->pool_debugfs_entry);
-	lov_ost_pool_free(&new_pool->pool_obds);
+	tgt_pool_free(&new_pool->pool_obds);
 	kfree(new_pool);
 
 	return rc;
@@ -490,7 +386,7 @@ int lov_pool_add(struct obd_device *obd, char *poolname, char *ostname)
 		goto out;
 	}
 
-	rc = lov_ost_pool_add(&pool->pool_obds, lov_idx, lov->lov_tgt_size);
+	rc = tgt_pool_add(&pool->pool_obds, lov_idx, lov->lov_tgt_size);
 	if (rc)
 		goto out;
 
@@ -542,7 +438,7 @@ int lov_pool_remove(struct obd_device *obd, char *poolname, char *ostname)
 		goto out;
 	}
 
-	lov_ost_pool_remove(&pool->pool_obds, lov_idx);
+	tgt_pool_remove(&pool->pool_obds, lov_idx);
 
 	CDEBUG(D_CONFIG, "%s removed from " LOV_POOLNAMEF "\n", ostname,
 	       poolname);
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index de37a89..1c46ea4 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,5 +8,5 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o integrity.o obd_cksum.o lu_tgt_descs.o \
-	      range_lock.o
+	      jobid.o integrity.o obd_cksum.o range_lock.o \
+	      lu_tgt_descs.o lu_tgt_pool.o
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
new file mode 100644
index 0000000..fc5e298
--- /dev/null
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -0,0 +1,241 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright  2008 Sun Microsystems, Inc. All rights reserved
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2017, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+/*
+ * lustre/target/tgt_pool.c
+ *
+ * This file handles creation, lookup, and removal of pools themselves, as
+ * well as adding and removing targets to pools.
+ *
+ * Author: Jacques-Charles LAFOUCRIERE <jc.lafoucriere@cea.fr>
+ * Author: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
+ * Author: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
+ */
+
+#define DEBUG_SUBSYSTEM S_CLASS
+
+#include <linux/libcfs/libcfs_private.h>
+#include <obd_target.h>
+#include <obd_support.h>
+
+/**
+ * Initialize the pool data structures at startup.
+ *
+ * Allocate and initialize the pool data structures with the specified
+ * array size.  If pool count is not specified (\a count == 0), then
+ * POOL_INIT_COUNT will be used.  Allocating a non-zero initial array
+ * size avoids the need to reallocate as new pools are added.
+ *
+ * @op		pool structure
+ * @count	initial size of the target op_array[] array
+ *
+ * Return:	0 indicates successful pool initialization
+ *		negative error number on failure
+ */
+#define POOL_INIT_COUNT 2
+int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count)
+{
+	if (count == 0)
+		count = POOL_INIT_COUNT;
+	op->op_array = NULL;
+	op->op_count = 0;
+	init_rwsem(&op->op_rw_sem);
+	op->op_size = count * sizeof(op->op_array[0]);
+	op->op_array = kcalloc(count, sizeof(op->op_array[0]),
+			       GFP_KERNEL);
+	if (!op->op_array) {
+		op->op_size = 0;
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(tgt_pool_init);
+
+/**
+ * Increase the op_array size to hold more targets in this pool.
+ *
+ * The size is increased to at least \a min_count, but may be larger
+ * for an existing pool since ->op_array[] is growing exponentially.
+ * Caller must hold write op_rwlock.
+ *
+ * @op		pool structure
+ * @min_count	minimum number of entries to handle
+ *
+ * Return:	0 on success
+ *		negative error number on failure.
+ */
+int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count)
+{
+	u32 *new;
+	u32 new_size;
+
+	LASSERT(min_count != 0);
+
+	if (op->op_count * sizeof(op->op_array[0]) < op->op_size)
+		return 0;
+
+	new_size = max_t(u32, min_count * sizeof(op->op_array[0]),
+			 2 * op->op_size);
+	new = kzalloc(new_size, GFP_KERNEL);
+	if (!new)
+		return -ENOMEM;
+
+	/* copy old array to new one */
+	memcpy(new, op->op_array, op->op_size);
+	kfree(op->op_array);
+	op->op_array = new;
+	op->op_size = new_size;
+
+	return 0;
+}
+EXPORT_SYMBOL(tgt_pool_extend);
+
+/**
+ * Add a new target to an existing pool.
+ *
+ * Add a new target device to the pool previously created and returned by
+ * lod_pool_new().  Each target can only be in each pool at most one time.
+ *
+ * @op		target pool to add new entry
+ * @idx		pool index number to add to the \a op array
+ * @min_count	minimum number of entries to expect in the pool
+ *
+ * Return:	0 if target could be added to the pool
+ *		negative error if target \a idx was not added
+ */
+int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
+{
+	unsigned int i;
+	int rc = 0;
+
+	down_write(&op->op_rw_sem);
+
+	rc = tgt_pool_extend(op, min_count);
+	if (rc)
+		goto out;
+
+	/* search ost in pool array */
+	for (i = 0; i < op->op_count; i++) {
+		if (op->op_array[i] == idx) {
+			rc = -EEXIST;
+			goto out;
+		}
+	}
+	/* ost not found we add it */
+	op->op_array[op->op_count] = idx;
+	op->op_count++;
+out:
+	up_write(&op->op_rw_sem);
+	return rc;
+}
+EXPORT_SYMBOL(tgt_pool_add);
+
+/**
+ * Remove an existing pool from the system.
+ *
+ * The specified pool must have previously been allocated by
+ * lod_pool_new() and not have any target members in the pool.
+ * If the removed target is not the last, compact the array
+ * to remove empty spaces.
+ *
+ * @op		pointer to the original data structure
+ * @idx		target index to be removed
+ *
+ * Return:	0 on success
+ *		negative error number on failure
+ */
+int tgt_pool_remove(struct lu_tgt_pool *op, u32 idx)
+{
+	unsigned int i;
+
+	down_write(&op->op_rw_sem);
+
+	for (i = 0; i < op->op_count; i++) {
+		if (op->op_array[i] == idx) {
+			memmove(&op->op_array[i], &op->op_array[i + 1],
+				(op->op_count - i - 1) *
+				sizeof(op->op_array[0]));
+			op->op_count--;
+			up_write(&op->op_rw_sem);
+			return 0;
+		}
+	}
+
+	up_write(&op->op_rw_sem);
+	return -EINVAL;
+}
+EXPORT_SYMBOL(tgt_pool_remove);
+
+int tgt_check_index(int idx, struct lu_tgt_pool *osts)
+{
+	int rc = 0, i;
+
+	down_read(&osts->op_rw_sem);
+	for (i = 0; i < osts->op_count; i++) {
+		if (osts->op_array[i] == idx)
+			goto out;
+	}
+	rc = -ENOENT;
+out:
+	up_read(&osts->op_rw_sem);
+	return rc;
+}
+EXPORT_SYMBOL(tgt_check_index);
+
+/**
+ * Free the pool after it was emptied and removed from /proc.
+ *
+ * Note that all of the child/target entries referenced by this pool
+ * must have been removed by lod_ost_pool_remove() before it can be
+ * deleted from memory.
+ *
+ * @op		pool to be freed.
+ *
+ * Return:	0 on success or if pool was already freed
+ */
+int tgt_pool_free(struct lu_tgt_pool *op)
+{
+	if (op->op_size == 0)
+		return 0;
+
+	down_write(&op->op_rw_sem);
+
+	kfree(op->op_array);
+	op->op_array = NULL;
+	op->op_count = 0;
+	op->op_size = 0;
+
+	up_write(&op->op_rw_sem);
+	return 0;
+}
+EXPORT_SYMBOL(tgt_pool_free);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
