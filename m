Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3236FC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:35:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15S9657Pz22Xv;
	Mon, 23 Jan 2023 15:10:49 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Ny05B2z22Qv
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:08:01 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 98565E00;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 96AB35898C; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:45 -0500
Message-Id: <1674514855-15399-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/42] lustre: enc: S_ENCRYPTED flag on OST
 objects for enc files
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Add a dumb encryption context on OST objects being created, when the
LUSTRE_ENCRYPT_FL flag gets set in the LMA, for ldiskfs backend
targets. This leads ldiskfs to internally set the LDISKFS_ENCRYPT_FL
flag on the on-disk inode. Also, it makes e2fsprogs happy to see an
enc ctx for an inode that has the LDISKFS_ENCRYPT_FL flag.

Add a dumb encryption context on OST objects being opened, if there is
not already one, for ldiskfs backend targets. This is done by adding
the LUSTRE_ENCRYPT_FL flag if necessary, at the same time as atime
gets updated. It is some sort of live self-check that fixes OST
objects created with an older Lustre version.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16091
Lustre-commit: 348446d6370b3f63f ("LU-16091 enc: S_ENCRYPTED flag on OST objects for enc files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48198
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/file.c          |  5 +++++
 fs/lustre/llite/llite_lib.c     |  5 +++++
 fs/lustre/osc/osc_request.c     | 10 ++++++++++
 4 files changed, 21 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index b58c1df4b538..a2930c800736 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -509,6 +509,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LFSCK_NO_DOUBLESCAN			0x160c
 #define OBD_FAIL_LFSCK_INVALID_PFID			0x1619
 #define OBD_FAIL_LFSCK_BAD_NAME_HASH			0x1628
+#define OBD_FAIL_LFSCK_NO_ENCFLAG			0x1632
 
 /* UPDATE */
 #define OBD_FAIL_UPDATE_OBJ_NET				0x1700
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index dac829fb977e..e343fc83d707 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5338,6 +5338,11 @@ int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
 	stat->attributes_mask |= STATX_ATTR_ENCRYPTED;
 #endif
 	stat->attributes |= ll_inode_to_ext_flags(inode->i_flags);
+	/* if Lustre specific LUSTRE_ENCRYPT_FL flag is set, also set
+	 * ext4 equivalent to please statx
+	 */
+	if (stat->attributes & LUSTRE_ENCRYPT_FL)
+		stat->attributes |= STATX_ATTR_ENCRYPTED;
 	stat->result_mask &= request_mask;
 
 	ll_stats_ops_tally(sbi, LPROC_LL_GETATTR,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4bc91dddb6a7..30056a6e26b2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2873,6 +2873,11 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
 		flags = body->mbo_flags;
+		/* if Lustre specific LUSTRE_ENCRYPT_FL flag is set, also set
+		 * ext4 equivalent to please lsattr and other e2fsprogs tools
+		 */
+		if (flags & LUSTRE_ENCRYPT_FL)
+			flags |= STATX_ATTR_ENCRYPTED;
 
 		ptlrpc_req_finished(req);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index fb0facc8ddd1..bd294c5085d8 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1792,6 +1792,16 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	else /* short i/o */
 		ioobj_max_brw_set(ioobj, 0);
 
+	if (inode && IS_ENCRYPTED(inode) &&
+	    fscrypt_has_encryption_key(inode) &&
+	    !OBD_FAIL_CHECK(OBD_FAIL_LFSCK_NO_ENCFLAG)) {
+		if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
+			body->oa.o_valid |= OBD_MD_FLFLAGS;
+			body->oa.o_flags = 0;
+		}
+		body->oa.o_flags |= LUSTRE_ENCRYPT_FL;
+	}
+
 	if (short_io_size != 0) {
 		if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
 			body->oa.o_valid |= OBD_MD_FLFLAGS;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
