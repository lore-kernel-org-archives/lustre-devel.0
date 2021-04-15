Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2A33C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 807C4610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 807C4610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C545732F7F2;
	Wed, 14 Apr 2021 21:04:20 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AE8E132F66C
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AA78F100F363;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A8D8391884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:26 -0400
Message-Id: <1618459361-17909-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/49] lustre: lov: cancel layout lock on
 replay deadlock
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
Cc: Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

layout locks are not replayed and instead cancelled as unused, what
requires to take lov_conf_lock. the semaphore may be already taken by
cl_lock_flush() which prepares a new IO which is not be able to be
sent to MDS as it is in the recovery.

HPE-bug-id: LUS-9232
WC-bug-id: https://jira.whamcloud.com/browse/LU-14182
Lustre-commit: 68fb53ad4bb2dbc ("LU-14182 lov: cancel layout lock on replay deadlock")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/40867
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Andriy Skulysh <askulysh@gmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/ldlm/ldlm_request.c   |  2 ++
 fs/lustre/llite/namei.c         |  2 ++
 fs/lustre/lov/lov_cl_internal.h | 10 +++++++---
 fs/lustre/lov/lov_object.c      | 44 ++++++++++++++++++++++++-----------------
 5 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 152f95c..b2f97f1 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -308,6 +308,7 @@
 
 #define OBD_FAIL_LDLM_GRANT_CHECK			0x32a
 #define OBD_FAIL_LDLM_LOCAL_CANCEL_PAUSE		0x32c
+#define OBD_FAIL_LDLM_REPLAY_PAUSE			0x32e
 
 /* LOCKLESS IO */
 #define OBD_FAIL_LDLM_SET_CONTENTION			0x385
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index d8ca744..3527678 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2220,6 +2220,8 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 	       "Dropping as many unused locks as possible before replay for namespace %s (%d)\n",
 	       ldlm_ns_name(ns), ns->ns_nr_unused);
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
+
 	/*
 	 * We don't need to care whether or not LRU resize is enabled
 	 * because the LDLM_LRU_FLAG_NO_WAIT policy doesn't use the
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1095fa9..654d065 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -204,6 +204,8 @@ static int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
+
 	/* reach MDC layer to flush data under  the DoM ldlm lock */
 	rc = cl_object_flush(env, lli->lli_clob, lock);
 	if (rc == -ENODATA) {
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index e9ef5aa..f231be9 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -251,6 +251,11 @@ struct lov_mirror_entry {
 	unsigned short	lre_end;	/* end index of this mirror */
 };
 
+enum lov_object_flags {
+	/* Layout is invalid, set when layout lock is lost */
+	LO_LAYOUT_INVALID	= 0x1,
+};
+
 /**
  * lov-specific file state.
  *
@@ -281,10 +286,9 @@ struct lov_object {
 	 */
 	enum lov_layout_type	lo_type;
 	/**
-	 * True if layout is invalid. This bit is cleared when layout lock
-	 * is lost.
+	 * Object flags.
 	 */
-	bool			lo_layout_invalid;
+	unsigned long		lo_obj_flags;
 	/**
 	 * How many IOs are on going on this object. Layout can be changed
 	 * only if there is no active IO.
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index abe1cee..db4070f 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -177,7 +177,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		old_obj = lu_object_locate(&parent->coh_lu, &lov_device_type);
 		LASSERT(old_obj);
 		old_lov = cl2lov(lu2cl(old_obj));
-		if (old_lov->lo_layout_invalid) {
+		if (test_bit(LO_LAYOUT_INVALID, &old_lov->lo_obj_flags)) {
 			/* the object's layout has already changed but isn't
 			 * refreshed
 			 */
@@ -628,7 +628,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	LASSERT(lsm->lsm_entry_count > 0);
 	LASSERT(!lov->lo_lsm);
 	lov->lo_lsm = lsm_addref(lsm);
-	lov->lo_layout_invalid = true;
+	set_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
 
 	dump_lsm(D_INODE, lsm);
 
@@ -910,7 +910,8 @@ static void lov_fini_released(const struct lu_env *env, struct lov_object *lov,
 static int lov_print_empty(const struct lu_env *env, void *cookie,
 			   lu_printer_t p, const struct lu_object *o)
 {
-	(*p)(env, cookie, "empty %d\n", lu2lov(o)->lo_layout_invalid);
+	(*p)(env, cookie, "empty %d\n",
+	     test_bit(LO_LAYOUT_INVALID, &lu2lov(o)->lo_obj_flags));
 	return 0;
 }
 
@@ -923,8 +924,8 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 
 	(*p)(env, cookie, "entries: %d, %s, lsm{%p 0x%08X %d %u}:\n",
 	     lsm->lsm_entry_count,
-	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
-	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+	     test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags) ? "invalid" :
+	     "valid", lsm, lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
 	     lsm->lsm_layout_gen);
 
 	for (i = 0; i < lsm->lsm_entry_count; i++) {
@@ -953,8 +954,8 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 
 	(*p)(env, cookie,
 	     "released: %s, lsm{%p 0x%08X %d %u}:\n",
-	     lov->lo_layout_invalid ? "invalid" : "valid", lsm,
-	     lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+	     test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags) ? "invalid" :
+	     "valid", lsm, lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
 	     lsm->lsm_layout_gen);
 	return 0;
 }
@@ -967,7 +968,8 @@ static int lov_print_foreign(const struct lu_env *env, void *cookie,
 
 	(*p)(env, cookie,
 		"foreign: %s, lsm{%p 0x%08X %d %u}:\n",
-		lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+		test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags) ?
+		"invalid" : "valid", lsm,
 		lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
 		lsm->lsm_layout_gen);
 	(*p)(env, cookie,
@@ -1352,15 +1354,15 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 		dump_lsm(D_INODE, lsm);
 	}
 
-	lov_conf_lock(lov);
 	if (conf->coc_opc == OBJECT_CONF_INVALIDATE) {
-		lov->lo_layout_invalid = true;
+		set_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
 		result = 0;
-		goto out;
+		goto out_lsm;
 	}
 
+	lov_conf_lock(lov);
 	if (conf->coc_opc == OBJECT_CONF_WAIT) {
-		if (lov->lo_layout_invalid &&
+		if (test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags) &&
 		    atomic_read(&lov->lo_active_ios) > 0) {
 			lov_conf_unlock(lov);
 			result = lov_layout_wait(env, lov);
@@ -1378,26 +1380,31 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 	     (lov->lo_lsm->lsm_entries[0]->lsme_pattern ==
 	      lsm->lsm_entries[0]->lsme_pattern))) {
 		/* same version of layout */
-		lov->lo_layout_invalid = false;
+		clear_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
 		result = 0;
 		goto out;
 	}
 
 	/* will change layout - check if there still exists active IO. */
 	if (atomic_read(&lov->lo_active_ios) > 0) {
-		lov->lo_layout_invalid = true;
+		set_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
 		result = -EBUSY;
 		goto out;
 	}
 
 	result = lov_layout_change(env, lov, lsm, conf);
-	lov->lo_layout_invalid = result != 0;
+	if (result)
+		set_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
+	else
+		clear_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags);
 
 out:
 	lov_conf_unlock(lov);
+out_lsm:
 	lov_lsm_put(lsm);
-	CDEBUG(D_INODE, DFID " lo_layout_invalid=%d\n",
-	       PFID(lu_object_fid(lov2lu(lov))), lov->lo_layout_invalid);
+	CDEBUG(D_INODE, DFID " lo_layout_invalid=%u\n",
+	       PFID(lu_object_fid(lov2lu(lov))),
+	       test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags));
 	return result;
 }
 
@@ -2254,7 +2261,8 @@ static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 		lsm = lsm_addref(lov->lo_lsm);
 		CDEBUG(D_INODE, "lsm %p addref %d/%d by %p.\n",
 		       lsm, atomic_read(&lsm->lsm_refc),
-		       lov->lo_layout_invalid, current);
+		       test_bit(LO_LAYOUT_INVALID, &lov->lo_obj_flags),
+		       current);
 	}
 	lov_conf_thaw(lov);
 	return lsm;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
