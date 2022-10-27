Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E6F15FA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:27:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynkS5Lmyz21BT;
	Thu, 27 Oct 2022 07:14:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynkC4k5Pz1wLC
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:14:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 961BD100910E;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 94E55FD4E9; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:42 -0400
Message-Id: <1666879542-10737-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/15] lustre: use 'fallthrough' pseudo
 keyword for switch
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

From: Jian Yu <yujian@whamcloud.com>

'/* fallthrough */' hits implicit-fallthrough error with GCC 11.

This patch replaces the existing '/* fallthrough */' comments and
its variants with the 'fallthrough' pseudo keyword, which was added
by Linux kernel commit v5.4-rc2-141-g294f69e662d1.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15220
Lustre-commit: 5549b1b9e032c6eae ("LU-15220 lustre: use 'fallthrough' pseudo keyword for switch")
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46269
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Peter Jones <pjones@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c    |  2 +-
 fs/lustre/llite/dir.c            |  4 ++--
 fs/lustre/llite/file.c           |  8 ++++----
 fs/lustre/llite/llite_lib.c      |  4 ++--
 fs/lustre/llite/namei.c          |  6 +++---
 fs/lustre/lov/lov_object.c       |  2 +-
 fs/lustre/obdecho/echo_client.c  |  2 +-
 fs/lustre/osc/osc_cache.c        |  2 +-
 fs/lustre/ptlrpc/pack_generic.c  |  8 ++++----
 fs/lustre/ptlrpc/ptlrpc_module.c | 12 ++++++------
 10 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index cf5a290..8b244d7 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1372,7 +1372,7 @@ int ldlm_cli_cancel_list_local(struct list_head *cancels, int count,
 	case LDLM_IBITS:
 		if (ns->ns_cancel && ns->ns_cancel(lock) != 0)
 			break;
-		/* fall through */
+		fallthrough;
 	default:
 		result = LDLM_POLICY_SKIP_LOCK;
 		break;
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 451bd0e..abbba96 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -2017,9 +2017,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return rc;
 	}
 	case OBD_IOC_GETNAME_OLD:
-		/* fall through */
+		fallthrough;
 	case OBD_IOC_GETDTNAME:
-		/* fall through */
+		fallthrough;
 	case OBD_IOC_GETMDNAME:
 		return ll_get_obd_name(inode, cmd, arg);
 	case LL_IOC_FLUSHCTX:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f35cddc..350d5df 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -176,7 +176,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
 		op_data->op_attr_blocks += ((struct inode *)data)->i_blocks;
 		op_data->op_attr.ia_valid |= ATTR_SIZE;
 		op_data->op_xvalid |= OP_XVALID_BLOCKS;
-		/* fallthrough */
+		fallthrough;
 	case MDS_CLOSE_LAYOUT_SPLIT:
 	case MDS_CLOSE_LAYOUT_SWAP: {
 		struct split_param *sp = data;
@@ -3317,7 +3317,7 @@ static int ll_ladvise_sanity(struct inode *inode,
 			       ladvise_names[advice], rc);
 			goto out;
 		}
-		/* fallthrough */
+		fallthrough;
 	case LU_LADVISE_WILLREAD:
 	case LU_LADVISE_DONTNEED:
 	default:
@@ -4028,9 +4028,9 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		return 0;
 	}
 	case OBD_IOC_GETNAME_OLD:
-		/* fall through */
+		fallthrough;
 	case OBD_IOC_GETDTNAME:
-		/* fall through */
+		fallthrough;
 	case OBD_IOC_GETMDNAME:
 		return ll_get_obd_name(inode, cmd, arg);
 	case LL_IOC_HSM_STATE_GET: {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 130a723..3dc0030 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1057,7 +1057,7 @@ static int ll_options(char *options, struct super_block *sb)
 
 		case LL_SBI_CHECKSUM:
 			sbi->ll_checksum_set = 1;
-			/* fall through */
+			fallthrough;
 		case LL_SBI_USER_XATTR:
 		case LL_SBI_USER_FID2PATH:
 		case LL_SBI_LRU_RESIZE:
@@ -1135,7 +1135,7 @@ static int ll_options(char *options, struct super_block *sb)
 				LCONSOLE_ERROR_MSG(0x152,
 						   "invalid %s option\n", s1);
 			}
-		/* fall through */
+		fallthrough;
 		default:
 			break;
 		}
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 8b21effc..5ac634c 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -410,13 +410,13 @@ int ll_md_need_convert(struct ldlm_lock *lock)
 	switch (lock->l_req_mode) {
 	case LCK_PR:
 		mode = LCK_PR;
-		/* fall-through */
+		fallthrough;
 	case LCK_PW:
 		mode |= LCK_CR;
 		break;
 	case LCK_CW:
 		mode = LCK_CW;
-		/* fall-through */
+		fallthrough;
 	case LCK_CR:
 		mode |= LCK_CR;
 		break;
@@ -1784,7 +1784,7 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 	case 0:
 		mode |= S_IFREG;
 		/* for mode = 0 case */
-		/* fall through */
+		fallthrough;
 	case S_IFREG:
 	case S_IFCHR:
 	case S_IFBLK:
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 5245fd6..34cb6a0 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -2308,7 +2308,7 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 		}
 		case LLT_RELEASED:
 		case LLT_EMPTY:
-			/* fall through */
+			fallthrough;
 		case LLT_FOREIGN:
 			break;
 		default:
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index f25ea41..d7de6e4 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1072,7 +1072,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 		}
 
 		rw = OBD_BRW_WRITE;
-		/* fall through */
+		fallthrough;
 	case OBD_IOC_BRW_READ:
 		rc = echo_client_brw_ioctl(env, rw, exp, data);
 		goto out;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 12d9ab5..e563809 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -230,7 +230,7 @@ static int __osc_extent_sanity_check(struct osc_extent *ext,
 			rc = 65;
 			goto out;
 		}
-		/* fall through */
+		fallthrough;
 	default:
 		if (atomic_read(&ext->oe_users) > 0) {
 			rc = 70;
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 9acea24..9a0341c 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -783,7 +783,7 @@ u32 lustre_msg_get_flags(struct lustre_msg *msg)
 
 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
 	}
-	/* fall through */
+	fallthrough;
 	default:
 		/* flags might be printed in debug code while message
 		 * uninitialized
@@ -851,7 +851,7 @@ u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
 
 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
 	}
-	/* fall through */
+	fallthrough;
 	default:
 		return 0;
 	}
@@ -1032,7 +1032,7 @@ int lustre_msg_get_status(struct lustre_msg *msg)
 
 		CERROR("invalid msg %p: no ptlrpc body!\n", msg);
 	}
-	/* fall through */
+	fallthrough;
 	default:
 		/* status might be printed in debug code while message
 		 * uninitialized
@@ -2069,7 +2069,7 @@ void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 	switch (lum->lum_magic) {
 	case LMV_USER_MAGIC_SPECIFIC:
 		count = lum->lum_stripe_count;
-		/* fallthrough */
+		fallthrough;
 	case __swab32(LMV_USER_MAGIC_SPECIFIC):
 		lustre_swab_lmv_user_md_objects(lum->lum_objects, count);
 		break;
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 7e29a91..95a29b2 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -135,23 +135,23 @@ static int __init ptlrpc_init(void)
 	switch (cleanup_phase) {
 	case 8:
 		ptlrpc_nrs_fini();
-		/* Fall through */
+		fallthrough;
 	case 7:
 		sptlrpc_fini();
-		/* Fall through */
+		fallthrough;
 	case 6:
 		ldlm_exit();
-		/* Fall through */
+		fallthrough;
 	case 5:
 		ptlrpc_connection_fini();
-		/* Fall through */
+		fallthrough;
 	case 3:
 		ptlrpc_request_cache_fini();
-		/* Fall through */
+		fallthrough;
 	case 1:
 		ptlrpc_hr_fini();
 		req_layout_fini();
-		/* Fall through */
+		fallthrough;
 	default:
 		break;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
