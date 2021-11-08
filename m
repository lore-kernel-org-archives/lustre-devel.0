Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29ED1C433EF
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:34 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BEC4261027
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org BEC4261027
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AE28021F294;
	Mon,  8 Nov 2021 07:08:19 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 31DCE21CA71
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:52 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3A841222E;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 397C0E07E1; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:43 -0500
Message-Id: <1636384063-13838-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/15] lustre: lmv: update default LMV upon
 any change
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

max_inherit and max_inherit_rr was newly added, and they are missing
in lsm_md_eq(), therefore client may not update default LMV when
either of these two fields is changed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15070
Lustre-commit: f3314706b4e5c21f1 ("LU-15070 llite: update default LMV upon any change")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45237
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 6861dd0..b1d8ed9 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -93,6 +93,8 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 	    lsm1->lsm_md_stripe_count != lsm2->lsm_md_stripe_count ||
 	    lsm1->lsm_md_master_mdt_index != lsm2->lsm_md_master_mdt_index ||
 	    lsm1->lsm_md_hash_type != lsm2->lsm_md_hash_type ||
+	    lsm1->lsm_md_max_inherit != lsm2->lsm_md_max_inherit ||
+	    lsm1->lsm_md_max_inherit_rr != lsm2->lsm_md_max_inherit_rr ||
 	    lsm1->lsm_md_layout_version != lsm2->lsm_md_layout_version ||
 	    lsm1->lsm_md_migrate_offset !=
 				lsm2->lsm_md_migrate_offset ||
@@ -108,6 +110,12 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 				       &lsm2->lsm_md_oinfo[idx].lmo_fid))
 				return false;
 		}
+	} else if (lsm1->lsm_md_magic == LMV_USER_MAGIC_SPECIFIC) {
+		for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
+			if (lsm1->lsm_md_oinfo[idx].lmo_mds !=
+			    lsm2->lsm_md_oinfo[idx].lmo_mds)
+				return false;
+		}
 	}
 
 	return true;
@@ -122,13 +130,13 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 	 * terminated string so only print LOV_MAXPOOLNAME bytes.
 	 */
 	CDEBUG(mask,
-	       "magic %#x stripe count %d master mdt %d hash type %s:%#x max inherit %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
+	       "magic %#x stripe count %d master mdt %d hash type %s:%#x max-inherit %hhu max-inherit-rr %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
 	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
 	       lsm->lsm_md_master_mdt_index,
 	       valid_hash ? "invalid hash" :
 			    mdt_hash_name[lsm->lsm_md_hash_type & (LMV_HASH_TYPE_MAX - 1)],
 	       lsm->lsm_md_hash_type, lsm->lsm_md_max_inherit,
-	       lsm->lsm_md_layout_version,
+	       lsm->lsm_md_max_inherit_rr, lsm->lsm_md_layout_version,
 	       lsm->lsm_md_migrate_offset, lsm->lsm_md_migrate_hash,
 	       LOV_MAXPOOLNAME, lsm->lsm_md_pool_name);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
