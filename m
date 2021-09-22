Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B87BEC433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7BF176112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 7BF176112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EA0F621F1AD;
	Tue, 21 Sep 2021 19:20:39 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2D38B21F1AD
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3FD9348F;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3E36FFF4BE; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:59 -0400
Message-Id: <1632277201-6920-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/24] lustre: uapi: fixup UAPI headers for
 native Linux client.
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

This covers all the UAPI problems outside of the user land
wiretest utility. One set of problems is build and the second is
that UAPI header definitions are either user land only or never
used to valid data going to or from user land.

1) Use UAPI header definitions to validate data send to or from
   kernel space. We check lum_hash_type using LMV_HASH_TYPE_MASK.
   This avoids a round trip to the server which will report back
   an error. The other case is we check the values returned for
   LL_IOC_HSM_ACTION. We keep the original behavior of passing
   unknown data to the user land application but add debug
   logging if the data looks corrupt to help track down bug
   issues.

2) We can use QIF_DQBLKSIZE* instead of Lustre specific values
   for our quota handling. QIF_DQBLKSIZE* is a Linux UAPI quota
   value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13903
Lustre-commit: d963e66f609c3bf47 ("LU-13903 uapi: fixup UAPI headers for native Linux client.")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44664
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/dir.c                   |  5 +++++
 fs/lustre/llite/file.c                  | 19 ++++++++++++++++++-
 fs/lustre/ptlrpc/wiretest.c             |  5 +++++
 include/uapi/linux/lustre/lustre_user.h | 20 ++++++++++++++++++++
 4 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index f7216db..b7dd2aa 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -423,6 +423,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		},
 	};
 	bool encrypt = false;
+	int hash_flags;
 	int err;
 
 	if (unlikely(!lmv_user_magic_supported(lump->lum_magic)))
@@ -463,6 +464,10 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 					      LMV_HASH_TYPE_FNV_1A_64;
 	}
 
+	hash_flags = lump->lum_hash_type & ~LMV_HASH_TYPE_MASK;
+	if (hash_flags & ~LMV_HASH_FLAG_KNOWN)
+		return -EINVAL;
+
 	if (unlikely(!lmv_user_magic_supported(cpu_to_le32(lump->lum_magic))))
 		lustre_swab_lmv_user_md(lump);
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ab7c72a..f340d67 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3973,6 +3973,7 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	case LL_IOC_HSM_ACTION: {
 		struct md_op_data *op_data;
 		struct hsm_current_action *hca;
+		const char *action;
 		int rc;
 
 		hca = kzalloc(sizeof(*hca), GFP_KERNEL);
@@ -3988,10 +3989,26 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 
 		rc = obd_iocontrol(cmd, ll_i2mdexp(inode), sizeof(*op_data),
 				   op_data, NULL);
+		if (rc < 0)
+			goto skip_copy;
+
+		/* The hsm_current_action retreived from the server could
+		 * contain corrupt information. If it is incorrect data collect
+		 * debug information. We still send the data even if incorrect
+		 * to user land to handle.
+		 */
+		action = hsm_user_action2name(hca->hca_action);
+		if (strcmp(action, "UNKNOWN") == 0 ||
+		    hca->hca_state > HPS_DONE) {
+			CDEBUG(D_HSM,
+			       "HSM current state %s action %s, offset = %llu, length %llu\n",
+			       hsm_progress_state2name(hca->hca_state), action,
+			       hca->hca_location.offset, hca->hca_location.length);
+		}
 
 		if (copy_to_user((char __user *)arg, hca, sizeof(*hca)))
 			rc = -EFAULT;
-
+skip_copy:
 		ll_finish_md_op_data(op_data);
 		kfree(hca);
 		return rc;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index b063cb9..1e89974 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1908,6 +1908,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(union lquota_id) == 16, "found %lld\n",
 		 (long long)(int)sizeof(union lquota_id));
 
+	LASSERTF(QIF_DQBLKSIZE_BITS == 10, "found %lld\n",
+		 (long long)QIF_DQBLKSIZE_BITS);
+	LASSERTF(QIF_DQBLKSIZE == 1024, "found %lld\n",
+		 (long long)QIF_DQBLKSIZE);
+
 	/* Checks for struct obd_quotactl */
 	LASSERTF((int)sizeof(struct obd_quotactl) == 112, "found %lld\n",
 		 (long long)(int)sizeof(struct obd_quotactl));
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 1940e52..5c4dadf 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1877,6 +1877,26 @@ enum hsm_states {
  */
 #define HSM_FLAGS_MASK  (HSM_USER_MASK | HSM_STATUS_MASK)
 
+/**
+ * HSM request progress state
+ */
+enum hsm_progress_states {
+	HPS_NONE	= 0,
+	HPS_WAITING	= 1,
+	HPS_RUNNING	= 2,
+	HPS_DONE	= 3,
+};
+
+static inline const char *hsm_progress_state2name(enum hsm_progress_states s)
+{
+	switch  (s) {
+	case HPS_WAITING:	return "waiting";
+	case HPS_RUNNING:	return "running";
+	case HPS_DONE:		return "done";
+	default:		return "unknown";
+	}
+}
+
 struct hsm_extent {
 	__u64 offset;
 	__u64 length;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
