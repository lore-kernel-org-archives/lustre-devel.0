Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FCC1C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:40:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 367FD60EBB
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:40:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 367FD60EBB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5CA5E380B25;
	Mon, 11 Oct 2021 10:40:58 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 82E9121FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B4E64268;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AE6ADA56A1; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:36 -0400
Message-Id: <1633974049-26490-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/20] lustre: lov: prefer mirrors on
 non-rotational OSTs
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

consider non-rotational OSTs as preferred unless explicit prefer
flag is set on a mirror.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14996
Lustre-commit: 8507472dd37ebc07 ("LU-14996 lov: prefer mirrors on non-rotational OSTs")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44883
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h |  5 +++--
 fs/lustre/lov/lov_object.c      | 26 ++++++++++++++++++++++----
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 7fcc327..d48e2df3 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -225,6 +225,7 @@ struct lov_layout_dom {
 struct lov_layout_entry {
 	u32					lle_type;
 	unsigned int				lle_valid:1;
+	unsigned int				lle_preference;
 	struct lu_extent			*lle_extent;
 	struct lov_stripe_md_entry		*lle_lsme;
 	struct lov_comp_layout_entry_ops	*lle_comp_ops;
@@ -236,12 +237,12 @@ struct lov_layout_entry {
 
 struct lov_mirror_entry {
 	unsigned short	lre_mirror_id;
-	unsigned short	lre_preferred:1,
-			lre_stale:1,	/* set if any components is stale */
+	unsigned short	lre_stale:1,	/* set if any components is stale */
 			lre_valid:1,	/* set if at least one of components
 					 * in this mirror is valid
 					 */
 			lre_foreign:1;	/* set if it is a foreign component */
+	int		lre_preference;	/* overall preference of this mirror */
 
 	unsigned short	lre_start;	/* index to lo_entries, start index of
 					 * this mirror
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 16fed09..ff0f7fa 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -234,6 +234,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 		struct lov_oinfo *oinfo = lse->lsme_oinfo[i];
 		int ost_idx = oinfo->loi_ost_idx;
 		struct cl_device *subdev;
+		struct obd_export *exp;
 
 		if (lov_oinfo_is_dummy(oinfo))
 			continue;
@@ -250,6 +251,13 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 			goto out;
 		}
 
+		exp = dev->ld_lov->lov_tgts[ost_idx]->ltd_exp;
+		if (likely(exp)) {
+			/* the more fast OSTs the better */
+			if (exp->exp_obd->obd_osfs.os_state & OS_STATFS_NONROT)
+				lle->lle_preference++;
+		}
+
 		subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
 		subconf->u.coc_oinfo = oinfo;
 		LASSERTF(subdev, "not init ost %d\n", ost_idx);
@@ -621,7 +629,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	unsigned int mirror_count;
 	int result = 0;
 	unsigned int seq;
-	int i, j;
+	int i, j, preference;
 	bool dom_size = 0;
 
 	LASSERT(lsm->lsm_entry_count > 0);
@@ -661,6 +669,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 
 		lle->lle_lsme = lsm->lsm_entries[i];
 		lle->lle_type = lov_entry_type(lle->lle_lsme);
+		lle->lle_preference = 0;
 		switch (lle->lle_type) {
 		case LOV_PATTERN_RAID0:
 			lle->lle_comp_ops = &raid0_ops;
@@ -722,8 +731,8 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		/* entries must be sorted by mirrors */
 		lre->lre_mirror_id = mirror_id;
 		lre->lre_start = lre->lre_end = i;
-		lre->lre_preferred = !!(lle->lle_lsme->lsme_flags &
-					LCME_FL_PREF_RD);
+		lre->lre_preference = lle->lle_lsme->lsme_flags &
+					LCME_FL_PREF_RD ? 1000 : 0;
 		lre->lre_valid = lle->lle_valid;
 		lre->lre_stale = !lle->lle_valid;
 		lre->lre_foreign = lsme_is_foreign(lle->lle_lsme);
@@ -771,6 +780,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	 * so that different clients would use different mirrors for read.
 	 */
 	mirror_count = 0;
+	preference = -1;
 	seq = hash_long((unsigned long)lov, 8);
 	for (i = 0; i < comp->lo_mirror_count; i++) {
 		unsigned int idx = (i + seq) % comp->lo_mirror_count;
@@ -784,8 +794,16 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 
 		mirror_count++; /* valid mirror */
 
-		if (lre->lre_preferred || comp->lo_preferred_mirror < 0)
+		/* aggregated preference of all involved OSTs */
+		for (j = lre->lre_start; j <= lre->lre_end; j++) {
+			lre->lre_preference +=
+				comp->lo_entries[j].lle_preference;
+		}
+
+		if (lre->lre_preference > preference) {
+			preference = lre->lre_preference;
 			comp->lo_preferred_mirror = idx;
+		}
 	}
 	if (!mirror_count) {
 		CDEBUG(D_INODE, DFID
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
