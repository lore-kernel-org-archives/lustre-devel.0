Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DE71C433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3C89860EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 3C89860EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 52C4A380EA3;
	Mon, 11 Oct 2021 10:41:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DF0A921FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id CC3E1478;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CAF33D5A42; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:45 -0400
Message-Id: <1633974049-26490-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/20] lustre: obdclass: lu_ref_add() called
 in atomic context
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

For the native Linux client testing I turn on lu_ref
debugging. When turned on the following errors occur:

[ 2885.946815] Call Trace:
[ 2885.951240]  dump_stack+0x68/0x9b
[ 2885.956523]  ___might_sleep+0x205/0x260
[ 2885.962245]  lu_ref_add+0x25/0x40 [obdclass]
[ 2885.968442]  vvp_pgcache_current+0x101/0x1a0 [lustre]
[ 2885.975370]  seq_read+0x1ab/0x3c0

and

[ 7042.102529]  dump_stack+0x68/0x9b
[ 7042.107328]  ___might_sleep+0x205/0x260
[ 7042.112647]  lu_ref_add+0x25/0x40 [obdclass]
[ 7042.118385]  mdc_lock_upcall+0x154/0x4d0 [mdc]
[ 7042.124275]  mdc_enqueue_send+0x508/0x580 [mdc]
[ 7042.130225]  ? mdc_lock_lvb_update+0x280/0x280 [mdc]

This is easily fixed with introducing a lu_object_ref_add_atomic()
function.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15014
Lustre-commit: 5a37bc9577d4c871 ("LU-15014 obdclass: lu_ref_add() called in atomic context")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44969
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lu_object.h | 7 +++++++
 fs/lustre/llite/vvp_dev.c     | 2 +-
 fs/lustre/mdc/mdc_dev.c       | 2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 84e0489..146398a 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -829,6 +829,13 @@ static inline u32 lu_object_attr(const struct lu_object *o)
 	return o->lo_header->loh_attr;
 }
 
+static inline void lu_object_ref_add_atomic(struct lu_object *o,
+					    const char *scope,
+					    const void *source)
+{
+	lu_ref_add_atomic(&o->lo_header->loh_reference, scope, source);
+}
+
 static inline void lu_object_ref_add(struct lu_object *o,
 				     const char *scope,
 				     const void *source)
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index fda48bb..0c417d8 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -399,7 +399,7 @@ static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 				continue;
 
 			priv->vsp_clob = lu2cl(lu_obj);
-			lu_object_ref_add(lu_obj, "dump", current);
+			lu_object_ref_add_atomic(lu_obj, "dump", current);
 			priv->vsp_page_index = 0;
 		}
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 4777b47..b2f60ea 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -461,7 +461,7 @@ static void mdc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 	/* lock reference taken by ldlm_handle2lock_long() is
 	 * owned by osc_lock and released in osc_lock_detach()
 	 */
-	lu_ref_add(&dlmlock->l_reference, "osc_lock", oscl);
+	lu_ref_add_atomic(&dlmlock->l_reference, "osc_lock", oscl);
 	oscl->ols_has_ref = 1;
 
 	LASSERT(!oscl->ols_dlmlock);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
