Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A92FEC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0B674QNz1y2J;
	Fri, 14 Oct 2022 14:38:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B05Fz2z1xJR
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E3EBF1006F20;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D89B4DD53E; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:53 -0400
Message-Id: <1665783491-13827-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/20] lustre: obdclass: set OBD_MD_FLGROUP
 for ladvise RPC
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

ladvise RPC doesn't have OBD_MD_FLGROUP set, when RPC
reaches server, tgt_validate_obdo() will corrupt the FID
if it's seq is in FID_SEQ_NORMAL range.

Do not mess with seq in obdo_to_ioobj() and tgt_validate_obdo(),
since 2.0 all RPCs should have OBD_MD_FLGROUP set.

Add OBD_MD_FLGROUP for ladvise RPC to fix new client talking
to old servers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16057
Lustre-commit: bee803c6e440ba6b5 ("LU-16057 obdclass: set OBD_MD_FLGROUP for ladvise RPC")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/48080
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obdo.c | 3 ---
 fs/lustre/osc/osc_io.c    | 2 +-
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/lustre/obdclass/obdo.c b/fs/lustre/obdclass/obdo.c
index 7df4ff399890..9cafda16a95f 100644
--- a/fs/lustre/obdclass/obdo.c
+++ b/fs/lustre/obdclass/obdo.c
@@ -123,9 +123,6 @@ EXPORT_SYMBOL(obdo_from_inode);
 void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj)
 {
 	ioobj->ioo_oid = oa->o_oi;
-	if (unlikely(!(oa->o_valid & OBD_MD_FLGROUP)))
-		ostid_set_seq_mdt0(&ioobj->ioo_oid);
-
 	/* Since 2.4 this does not contain o_mode in the low 16 bits.
 	 * Instead, it holds (bd_md_max_brw - 1) for multi-bulk BRW RPCs
 	 */
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 655c7c68ab3a..4c9b3d2bb481 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -1036,7 +1036,7 @@ static int osc_io_ladvise_start(const struct lu_env *env,
 
 	memset(oa, 0, sizeof(*oa));
 	oa->o_oi = loi->loi_oi;
-	oa->o_valid = OBD_MD_FLID;
+	oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP;
 	obdo_set_parent_fid(oa, lio->li_fid);
 
 	ladvise = ladvise_hdr->lah_advise;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
