Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93ED5C432BE
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 52CF0611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 52CF0611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A47AA21E0B9;
	Sun, 22 Aug 2021 19:28:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B471421CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 206A0100BAF6;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 101EEB6C80; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:33 -0400
Message-Id: <1629685666-4533-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/15] lustre: pcc: add LCM_FL_PCC_RDONLY
 layout flag
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

From: Qian Yingjin <qian@ddn.com>

The upcoming new feature PCC-RO is combined with FLR and extend
the on-disk data strucutre 'enum lov_comp_md_flags' for layout
components. It adds a new layout flag: LCM_FL_PCC_RDONLY.

enum lov_comp_md_flags {
        LCM_FL_NONE             = 0x0,
        LCM_FL_RDONLY           = 0x1,
        LCM_FL_WRITE_PENDING    = 0x2,
        LCM_FL_SYNC_PENDING     = 0x3,
        LCM_FL_PCC_RDONLY       = 0x8,
        LCM_FL_FLR_MASK         = 0xB,
};

The LCM_FL_PCC_RDONLY flag, which is dedicated for PCC-RO, is
different from LCM_FL_RDONLY.
A PCC-RO cached file could be in the state:
- LCM_FL_PCC_RDONLY | LCM_FL_RDONLY: it means that all FLR
  components are synced and in up-to-date state. The replicated
  file is on read-only state. And then one client attaches the
  file into the PCC backend with PCC-RO mode.
- LCM_FL_PCC_RDONLY | LCM_FL_WRITE_PENDING: it means the file was
  once modified, the data content of layout components are not
  synced. MDT has already picked a promary replica and marked
  other components as STALE. At this time, a client can still
  PCC-RO attach the file. On this client, the primary component
  and the PCC copy are both in up-to-date state.

As a new LCM_FL_PCC_RDONLY flag is added, the old client may not
understand this new FLR layout flag, and may result in
inconsistent data access.

This patch adds this new flag for the purpose of compatibility and
interoperability.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13602
Lustre-commit: adc1bbbf20e0a8a5 ("LU-13602 pcc: add LCM_FL_PCC_RDONLY layout flag")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/40813
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             |  2 ++
 include/uapi/linux/lustre/lustre_user.h | 13 +++++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 7d504bd..b063cb9 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1727,6 +1727,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)LCM_FL_WRITE_PENDING);
 	LASSERTF(LCM_FL_SYNC_PENDING == 3, "found %lld\n",
 		 (long long)LCM_FL_SYNC_PENDING);
+	LASSERTF(LCM_FL_PCC_RDONLY == 8, "found %lld\n",
+		 (long long)LCM_FL_PCC_RDONLY);
 
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 7fcc009..1940e52 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -622,12 +622,13 @@ static inline __u16 mirror_id_of(__u32 id)
  * on-disk data for lcm_flags. Valid if lcm_magic is LOV_MAGIC_COMP_V1.
  */
 enum lov_comp_md_flags {
-	/* the least 2 bits are used by FLR to record file state */
-	LCM_FL_NONE             = 0,
-	LCM_FL_RDONLY           = 1,
-	LCM_FL_WRITE_PENDING    = 2,
-	LCM_FL_SYNC_PENDING     = 3,
-	LCM_FL_FLR_MASK         = 0x3,
+	/* the least 4 bits are used by FLR to record file state */
+	LCM_FL_NONE             = 0x0,
+	LCM_FL_RDONLY           = 0x1,
+	LCM_FL_WRITE_PENDING    = 0x2,
+	LCM_FL_SYNC_PENDING     = 0x3,
+	LCM_FL_PCC_RDONLY	= 0x8,
+	LCM_FL_FLR_MASK         = 0xB,
 };
 
 struct lov_comp_md_v1 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
