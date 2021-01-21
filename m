Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D76C433E6
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:45 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5ED4723A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ED4723A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9A00D21FD91;
	Thu, 21 Jan 2021 09:17:32 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9109621FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:06 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 241F21007887;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1A58CF0A7; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:24 -0500
Message-Id: <1611249422-556-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/39] lustre: ldlm: page discard speedup
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
Cc: Alexander Zarochentsev <c17826@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Zarochentsev <c17826@cray.com>

Improving check_and_discard_cb, allowing to cache
negative result of dlm lock lookup and avoid
excessive osc_dlm_lock_at_pgoff() calls.

HPE-bug-id: LUS-6432
WC-bug-id: https://jira.whamcloud.com/browse/LU-11290
Lustre-commit: 0f48cd0b9856fe ("LU-11290 ldlm: page discard speedup")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/39327
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  1 +
 fs/lustre/include/lustre_osc.h |  5 +++++
 fs/lustre/ldlm/ldlm_lock.c     | 16 +++++++++-----
 fs/lustre/osc/osc_cache.c      | 48 +++++++++++++++++++++++++++++++-----------
 fs/lustre/osc/osc_lock.c       |  3 +++
 5 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index f056c2d..e4c95a2 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -858,6 +858,7 @@ enum ldlm_match_flags {
 	LDLM_MATCH_UNREF	= BIT(0),
 	LDLM_MATCH_AST		= BIT(1),
 	LDLM_MATCH_AST_ANY	= BIT(2),
+	LDLM_MATCH_RIGHT	= BIT(3),
 };
 
 /**
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index ef5237b..e7bf392 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -186,6 +186,7 @@ struct osc_thread_info {
 	 */
 	pgoff_t			oti_next_index;
 	pgoff_t			oti_fn_index; /* first non-overlapped index */
+	pgoff_t			oti_ng_index; /* negative lock caching */
 	struct cl_sync_io	oti_anchor;
 	struct cl_req_attr	oti_req_attr;
 	struct lu_buf		oti_ladvise_buf;
@@ -248,6 +249,10 @@ enum osc_dap_flags {
 	 * check ast data is present, requested to cancel cb
 	 */
 	OSC_DAP_FL_AST	     = BIT(2),
+	/**
+	 * look at right region for the desired lock
+	 */
+	OSC_DAP_FL_RIGHT     = BIT(3),
 };
 
 /*
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 56f1550..b7ce0bb 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1093,8 +1093,9 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 
 	switch (lock->l_resource->lr_type) {
 	case LDLM_EXTENT:
-		if (lpol->l_extent.start > data->lmd_policy->l_extent.start ||
-		    lpol->l_extent.end < data->lmd_policy->l_extent.end)
+		if (!(data->lmd_match & LDLM_MATCH_RIGHT) &&
+		    (lpol->l_extent.start > data->lmd_policy->l_extent.start ||
+		     lpol->l_extent.end < data->lmd_policy->l_extent.end))
 			return false;
 
 		if (unlikely(match == LCK_GROUP) &&
@@ -1160,10 +1161,17 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 struct ldlm_lock *search_itree(struct ldlm_resource *res,
 			       struct ldlm_match_data *data)
 {
+	struct ldlm_extent ext = {
+		.start	= data->lmd_policy->l_extent.start,
+		.end	= data->lmd_policy->l_extent.end
+	};
 	int idx;
 
 	data->lmd_lock = NULL;
 
+	if (data->lmd_match & LDLM_MATCH_RIGHT)
+		ext.end = OBD_OBJECT_EOF;
+
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
 
@@ -1173,9 +1181,7 @@ struct ldlm_lock *search_itree(struct ldlm_resource *res,
 		if (!(tree->lit_mode & *data->lmd_mode))
 			continue;
 
-		ldlm_extent_search(&tree->lit_root,
-				   data->lmd_policy->l_extent.start,
-				   data->lmd_policy->l_extent.end,
+		ldlm_extent_search(&tree->lit_root, ext.start, ext.end,
 				   lock_matches, data);
 		if (data->lmd_lock)
 			return data->lmd_lock;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index ddf6fb1..d511ece 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -3207,28 +3207,51 @@ static bool check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct osc_object *osc = cbdata;
+	struct cl_page *page = ops->ops_cl.cpl_page;
 	pgoff_t index;
+	bool discard = false;
 
 	index = osc_index(ops);
-	if (index >= info->oti_fn_index) {
+	/* negative lock caching */
+	if (index < info->oti_ng_index) {
+		discard = true;
+	} else if (index >= info->oti_fn_index) {
 		struct ldlm_lock *tmp;
-		struct cl_page *page = ops->ops_cl.cpl_page;
 
 		/* refresh non-overlapped index */
 		tmp = osc_dlmlock_at_pgoff(env, osc, index,
-					   OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_AST);
+					   OSC_DAP_FL_TEST_LOCK |
+					   OSC_DAP_FL_AST | OSC_DAP_FL_RIGHT);
 		if (tmp) {
 			u64 end = tmp->l_policy_data.l_extent.end;
-			/* Cache the first-non-overlapped index so as to skip
-			 * all pages within [index, oti_fn_index). This is safe
-			 * because if tmp lock is canceled, it will discard
-			 * these pages.
-			 */
-			info->oti_fn_index = cl_index(osc2cl(osc), end + 1);
-			if (end == OBD_OBJECT_EOF)
-				info->oti_fn_index = CL_PAGE_EOF;
+			u64 start = tmp->l_policy_data.l_extent.start;
+
+			/* no lock covering this page */
+			if (index < cl_index(osc2cl(osc), start)) {
+				/* no lock at @index, first lock at @start */
+				info->oti_ng_index = cl_index(osc2cl(osc),
+							      start);
+				discard = true;
+			} else {
+				/* Cache the first-non-overlapped index so as to
+				 * skip all pages within [index, oti_fn_index).
+				 * This is safe because if tmp lock is canceled,
+				 * it will discard these pages.
+				 */
+				info->oti_fn_index = cl_index(osc2cl(osc),
+							      end + 1);
+				if (end == OBD_OBJECT_EOF)
+					info->oti_fn_index = CL_PAGE_EOF;
+			}
 			LDLM_LOCK_PUT(tmp);
-		} else if (cl_page_own(env, io, page) == 0) {
+		} else {
+			info->oti_ng_index = CL_PAGE_EOF;
+			discard = true;
+		}
+	}
+
+	if (discard) {
+		if (cl_page_own(env, io, page) == 0) {
 			/* discard the page */
 			cl_page_discard(env, io, page);
 			cl_page_disown(env, io, page);
@@ -3292,6 +3315,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 	cb = discard ? osc_discard_cb : check_and_discard_cb;
 	info->oti_fn_index = start;
 	info->oti_next_index = start;
+	info->oti_ng_index = 0;
 
 	osc_page_gang_lookup(env, io, osc,
 			     info->oti_next_index, end, cb, osc);
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 7bfcbfb..536142f2 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1282,6 +1282,9 @@ struct ldlm_lock *osc_obj_dlmlock_at_pgoff(const struct lu_env *env,
 	if (dap_flags & OSC_DAP_FL_CANCELING)
 		match_flags |= LDLM_MATCH_UNREF;
 
+	if (dap_flags & OSC_DAP_FL_RIGHT)
+		match_flags |= LDLM_MATCH_RIGHT;
+
 	/*
 	 * It is fine to match any group lock since there could be only one
 	 * with a uniq gid and it conflicts with all other lock modes too
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
