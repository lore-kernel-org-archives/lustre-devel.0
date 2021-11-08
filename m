Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E8DBC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DC3EC61027
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org DC3EC61027
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B0D6621F3C3;
	Mon,  8 Nov 2021 07:08:14 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C449521C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:50 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2AB4C2229;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2713AE07F4; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:38 -0500
Message-Id: <1636384063-13838-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/15] lustre: lov: fix error handling in
 lov_new_pool
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

- correct error handling in lov_new_pool - ENOMEM
  from tgt_pool_init may cause incorrect pool_count.
- optimisation in lu_tgt_pool_add. Do not extend
  a pool, if the target is already exists.

HPE-bug-id: LUS-6995
WC-bug-id: https://jira.whamcloud.com/browse/LU-15067
Lustre-commit: b6ac7490f3a30c80d ("LU-15067 lod: fix error handling in lod_new_pool")
Signed-off-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-on: https://review.whamcloud.com/45137
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Artem Blagodarenko <artem.blagodarenko@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pool.c         | 3 ++-
 fs/lustre/obdclass/lu_tgt_pool.c | 9 +++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 25e980f..267ac2d 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -270,7 +270,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	atomic_set(&new_pool->pool_refcount, 1);
 	rc = lu_tgt_pool_init(&new_pool->pool_obds, 0);
 	if (rc)
-		goto out_err;
+		goto out_free_pool;
 
 	/* get ref for debugfs file */
 	lov_pool_getref(new_pool);
@@ -311,6 +311,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	spin_unlock(&obd->obd_dev_lock);
 	debugfs_remove_recursive(new_pool->pool_debugfs_entry);
 	lu_tgt_pool_free(&new_pool->pool_obds);
+out_free_pool:
 	kfree(new_pool);
 
 	return rc;
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
index 8f52fb4..17bae54 100644
--- a/fs/lustre/obdclass/lu_tgt_pool.c
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -138,10 +138,6 @@ int lu_tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
 
 	down_write(&op->op_rw_sem);
 
-	rc = lu_tgt_pool_extend(op, min_count);
-	if (rc)
-		goto out;
-
 	/* search ost in pool array */
 	for (i = 0; i < op->op_count; i++) {
 		if (op->op_array[i] == idx) {
@@ -149,6 +145,11 @@ int lu_tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count)
 			goto out;
 		}
 	}
+
+	rc = lu_tgt_pool_extend(op, min_count);
+	if (rc)
+		goto out;
+
 	/* ost not found we add it */
 	op->op_array[op->op_count] = idx;
 	op->op_count++;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
