Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CBF1CC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:27:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2rf6XmYz1xs6;
	Fri, 21 Mar 2025 06:11:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nN3Lhzz1y4G
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:24 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8C27D17B5A8;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 8AA95106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:00 -0400
Message-ID: <20250321130711.3257092-18-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 17/27] lustre: client: use EOPNOTSUPP instead
 of ENOTSUPP
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Don't return NFS-specific error code ENOTSUPP back to userspace,
instead use EOPNOTSUPP.  ENOTSUPP does not print a useful error
message from strerror() if it is hit by an application.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14301
Lustre-commit: ffd2fc1e17822c013 ("LU-14301 client: use EOPNOTSUPP instead of ENOTSUPP")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51511
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c          | 4 ++--
 fs/lustre/llite/lcommon_misc.c | 2 +-
 fs/lustre/llite/lproc_llite.c  | 2 +-
 fs/lustre/lov/lov_object.c     | 4 ++--
 fs/lustre/mdc/lproc_mdc.c      | 2 +-
 fs/lustre/mdc/mdc_dev.c        | 2 +-
 fs/lustre/mdc/mdc_request.c    | 2 +-
 fs/lustre/osc/lproc_osc.c      | 2 +-
 fs/lustre/osc/osc_io.c         | 2 +-
 9 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 0c1b1ed31601..b628e11e759c 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1232,7 +1232,7 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 	default:
 		CERROR("%s: unsupported quotactl op: %#x: rc = %d\n",
 		       sbi->ll_fsname, cmd, -EOPNOTSUPP);
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	if (valid != QC_GENERAL) {
@@ -1670,7 +1670,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		case LOV_USER_MAGIC_V1:
 			break;
 		default:
-			rc = -ENOTSUPP;
+			rc = -EOPNOTSUPP;
 			goto out;
 		}
 
diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index 3b0c0f4a39f1..add1601510c7 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -140,7 +140,7 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 		cl_env_put(env, &refcheck);
 		/* Does not make sense to take GL for released layout */
 		if (rc > 0)
-			rc = -ENOTSUPP;
+			rc = -EOPNOTSUPP;
 		return rc;
 	}
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 4ea0bb2cbbaa..189dc31d4152 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1087,7 +1087,7 @@ static ssize_t xattr_cache_store(struct kobject *kobj,
 		return rc;
 
 	if (val && !test_bit(LL_SBI_XATTR_CACHE, sbi->ll_flags))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	sbi->ll_xattr_cache_enabled = val;
 	sbi->ll_xattr_cache_set = 1;
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 27f005c807fe..e9c3ace52bab 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1980,14 +1980,14 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		if (lsm->lsm_entry_count > 1 ||
 		    (lsm->lsm_entry_count == 1 &&
 		     lsm->lsm_entries[0]->lsme_stripe_count > 1)) {
-			rc = -ENOTSUPP;
+			rc = -EOPNOTSUPP;
 			goto out_lsm;
 		}
 	}
 
 	/* No support for DOM layout yet. */
 	if (lsme_is_dom(lsm->lsm_entries[0])) {
-		rc = -ENOTSUPP;
+		rc = -EOPNOTSUPP;
 		goto out_lsm;
 	}
 
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index d8dded8ed8a6..53beafb845e4 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -140,7 +140,7 @@ static ssize_t mdc_checksum_type_seq_write(struct file *file,
 				obd->u.cli.cl_cksum_type = BIT(i);
 				rc = count;
 			} else {
-				rc = -ENOTSUPP;
+				rc = -EOPNOTSUPP;
 			}
 			break;
 		}
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 672015546f3a..1c993fd3cd7f 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1294,7 +1294,7 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 		slice->cis_io->ci_result = 0;
 		if (!(oio->oi_oa.o_valid &
 		      (OBD_MD_LAYOUT_VERSION | OBD_MD_FLDATAVERSION)))
-			slice->cis_io->ci_result = -ENOTSUPP;
+			slice->cis_io->ci_result = -EOPNOTSUPP;
 
 		if (oio->oi_oa.o_valid & OBD_MD_LAYOUT_VERSION)
 			dv->dv_layout_version = oio->oi_oa.o_layout_version;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index ad625fbbd666..d0f51b2e0051 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -102,7 +102,7 @@ static int mdc_get_root(struct obd_export *exp, const char *fileset,
 	int rc;
 
 	if (fileset && !(exp_connect_flags(exp) & OBD_CONNECT_SUBTREE))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_GET_ROOT);
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 2e2cec9db148..9d20555d80d3 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -438,7 +438,7 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 				obd->u.cli.cl_cksum_type = BIT(i);
 				rc = count;
 			} else {
-				rc = -ENOTSUPP;
+				rc = -EOPNOTSUPP;
 			}
 			break;
 		}
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 5b4abb1cb625..f97808f56138 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -850,7 +850,7 @@ static void osc_io_data_version_end(const struct lu_env *env,
 		slice->cis_io->ci_result = 0;
 		if (!(oa->o_valid &
 		      (OBD_MD_LAYOUT_VERSION | OBD_MD_FLDATAVERSION)))
-			slice->cis_io->ci_result = -ENOTSUPP;
+			slice->cis_io->ci_result = -EOPNOTSUPP;
 
 		if (oa->o_valid & OBD_MD_LAYOUT_VERSION)
 			dv->dv_layout_version = oa->o_layout_version;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
