Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4FF98C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1BECE3AD51D;
	Wed, 29 Dec 2021 06:51:55 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E7E8C3AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 862291006F06;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8073AD9E70; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:17 -0500
Message-Id: <1640789487-22279-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/13] lustre: quota: fallocate send UID/GID
 for quota
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

Calling fallocate() on a newly created file did not account quota
usage properly because the OST object did not have a UID/GID
assigned yet. Update the fallocate code in the OSC to always send
the file UID/GID/PROJID to the OST so that the object ownership
can be updated before space is allocated.

Fixes: d748d2ffa1bc ("lustre: fallocate: Implement fallocate preallocate operation")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15167
Lustre-commit: 789038c97ae107287 ("LU-15167 quota: fallocate send UID/GID for quota")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/45475
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 2 ++
 fs/lustre/llite/file.c        | 8 ++++++++
 fs/lustre/lov/lov_io.c        | 4 ++++
 fs/lustre/osc/osc_io.c        | 8 +++++++-
 4 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index a65240b..1746c4e 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1877,6 +1877,8 @@ struct cl_io {
 			int			sa_falloc_mode;
 			loff_t			sa_falloc_offset;
 			loff_t			sa_falloc_end;
+			uid_t			sa_falloc_uid;
+			gid_t			sa_falloc_gid;
 		} ci_setattr;
 		struct cl_data_version_io {
 			u64			dv_data_version;
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 898db80..20571c9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5244,6 +5244,14 @@ int cl_falloc(struct file *file, struct inode *inode, int mode, loff_t offset,
 	io->u.ci_setattr.sa_falloc_offset = offset;
 	io->u.ci_setattr.sa_falloc_end = offset + len;
 	io->u.ci_setattr.sa_subtype = CL_SETATTR_FALLOCATE;
+
+	CDEBUG(D_INODE, "UID %u GID %u\n",
+	       from_kuid(&init_user_ns, inode->i_uid),
+	       from_kgid(&init_user_ns, inode->i_gid));
+
+	io->u.ci_setattr.sa_falloc_uid = from_kuid(&init_user_ns, inode->i_uid);
+	io->u.ci_setattr.sa_falloc_gid = from_kgid(&init_user_ns, inode->i_gid);
+
 	if (io->u.ci_setattr.sa_falloc_end > size) {
 		loff_t newsize = io->u.ci_setattr.sa_falloc_end;
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index d5f895f..8df13ee 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -680,6 +680,10 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 		if (cl_io_is_fallocate(io)) {
 			io->u.ci_setattr.sa_falloc_offset = start;
 			io->u.ci_setattr.sa_falloc_end = end;
+			io->u.ci_setattr.sa_falloc_uid =
+				parent->u.ci_setattr.sa_falloc_uid;
+			io->u.ci_setattr.sa_falloc_gid =
+				parent->u.ci_setattr.sa_falloc_gid;
 		}
 		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b867985..b84022b 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -669,7 +669,13 @@ static int osc_io_setattr_start(const struct lu_env *env,
 
 			oa->o_size = io->u.ci_setattr.sa_falloc_offset;
 			oa->o_blocks = io->u.ci_setattr.sa_falloc_end;
-			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
+			oa->o_uid = io->u.ci_setattr.sa_falloc_uid;
+			oa->o_gid = io->u.ci_setattr.sa_falloc_gid;
+			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS |
+				OBD_MD_FLUID | OBD_MD_FLGID;
+
+			CDEBUG(D_INODE, "size %llu blocks %llu uid %u gid %u\n",
+			       oa->o_size, oa->o_blocks, oa->o_uid, oa->o_gid);
 			result = osc_fallocate_base(osc_export(cl2osc(obj)),
 						    oa, osc_async_upcall,
 						    cbargs, falloc_mode);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
