Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8C5A3C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyry109r8z23Lc;
	Wed,  3 Aug 2022 18:39:53 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwj0k9gz21H0
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EF2AF100B036;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EDA878BBFC; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:11 -0400
Message-Id: <1659577097-19253-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/32] lustre: mdc: pack default LMV in open
 reply
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Add flag MDS_OPEN_DEFAULT_LMV to indicate that default LMV should be
packed in open reply, otherwise if open fetches LOOKUP lock, client
won't know directory has default LMV, and in subdir creation default
LMV won't take effect.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15850
Lustre-commit: f6e4272fb0be5b798 ("LU-15850 mdt: pack default LMV in open reply")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47576
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c                 | 1 +
 fs/lustre/mdc/mdc_locks.c               | 2 ++
 fs/lustre/ptlrpc/layout.c               | 1 +
 fs/lustre/ptlrpc/wiretest.c             | 2 ++
 include/uapi/linux/lustre/lustre_user.h | 5 ++++-
 5 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 51080a1..077639d 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -329,6 +329,7 @@ void mdc_open_pack(struct req_capsule *pill, struct md_op_data *op_data,
 			rec->cr_archive_id = op_data->op_archive_id;
 		}
 	}
+	cr_flags |= MDS_OPEN_DEFAULT_LMV;
 	set_mrc_cr_flags(rec, cr_flags);
 }
 
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index b86d1b9..2a9b9a8 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -393,6 +393,8 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 	 */
 	req_capsule_set_size(&req->rq_pill, &RMF_NIOBUF_INLINE, RCL_SERVER,
 			     sizeof(struct niobuf_remote));
+	req_capsule_set_size(&req->rq_pill, &RMF_DEFAULT_MDT_MD, RCL_SERVER,
+			     sizeof(struct lmv_user_md));
 	ptlrpc_request_set_replen(req);
 
 	/* Get real repbuf allocated size as rounded up power of 2 */
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 8725edd..82ec899 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -447,6 +447,7 @@
 	&RMF_NIOBUF_INLINE,
 	&RMF_FILE_SECCTX,
 	&RMF_FILE_ENCCTX,
+	&RMF_DEFAULT_MDT_MD,
 };
 
 static const struct req_msg_field *ldlm_intent_getattr_client[] = {
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 81e0485..60a7fd0 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2326,6 +2326,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_OPEN_RESYNC);
 	LASSERTF(MDS_OPEN_PCC == 00000000010000000000000ULL, "found 0%.22lloULL\n",
 		 (long long)MDS_OPEN_PCC);
+	LASSERTF(MDS_OPEN_DEFAULT_LMV == 00000000040000000000000ULL, "found 0%.22lloULL\n",
+		 (long long)MDS_OPEN_DEFAULT_LMV);
 	LASSERTF(LUSTRE_SYNC_FL == 0x00000008, "found 0x%.8x\n",
 		 LUSTRE_SYNC_FL);
 	LASSERTF(LUSTRE_IMMUTABLE_FL == 0x00000010, "found 0x%.8x\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index c57929b..7b79604 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1246,12 +1246,15 @@ enum la_valid {
 					      * for newly created file
 					      */
 #define MDS_OP_WITH_FID	  020000000000000ULL /* operation carried out by FID */
+#define MDS_OPEN_DEFAULT_LMV  040000000000000ULL /* open fetches default LMV */
 
+/* lustre internal open flags, which should not be set from user space */
 #define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
 			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
 			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
 			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC |	\
-			      MDS_OPEN_PCC | MDS_OP_WITH_FID)
+			      MDS_OPEN_PCC | MDS_OP_WITH_FID |		\
+			      MDS_OPEN_DEFAULT_LMV)
 
 /********* Changelogs **********/
 /** Changelog record types */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
