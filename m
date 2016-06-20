From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Sun, 19 Jun 2016 17:27:13 -0700
Subject: [lustre-devel] [PATCH v2 14/24] drivers: staging: lustre: Replace
	CURRENT_TIME with current_time()
In-Reply-To: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1466382443-11063-15-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, tglx@linutronix.de, torvalds@linux-foundation.org, tytso@mit.edu, viro@zeniv.linux.org.uk, y2038@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org

CURRENT_TIME macro is not appropriate for filesystems as it
doesn't use the right granularity for filesystem timestamps.
Use current_time() instead.

This is also in preparation for the patch that transitions
vfs timestamps to use 64 bit time and hence make them
y2038 safe. As part of the effort current_time() will be
extended to do range checks. Hence, it is necessary for all
file system timestamps to use current_time().

Also change format string for prints so that these are valid
when vfs is transitioned to use 64 bit timestamps.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel at lists.lustre.org
Acked-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c          | 16 ++++++++--------
 drivers/staging/lustre/lustre/llite/namei.c              |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c            |  6 +++---
 .../staging/lustre/lustre/obdclass/linux/linux-obdo.c    |  6 +++---
 drivers/staging/lustre/lustre/obdclass/obdo.c            |  6 +++---
 drivers/staging/lustre/lustre/osc/osc_io.c               |  2 +-
 6 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 96c7e9f..e5c44d8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1258,23 +1258,23 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
 	/* We mark all of the fields "set" so MDS/OST does not re-set them */
 	if (attr->ia_valid & ATTR_CTIME) {
-		attr->ia_ctime = CURRENT_TIME;
+		attr->ia_ctime = current_time(inode);
 		attr->ia_valid |= ATTR_CTIME_SET;
 	}
 	if (!(attr->ia_valid & ATTR_ATIME_SET) &&
 	    (attr->ia_valid & ATTR_ATIME)) {
-		attr->ia_atime = CURRENT_TIME;
+		attr->ia_atime = current_time(inode);
 		attr->ia_valid |= ATTR_ATIME_SET;
 	}
 	if (!(attr->ia_valid & ATTR_MTIME_SET) &&
 	    (attr->ia_valid & ATTR_MTIME)) {
-		attr->ia_mtime = CURRENT_TIME;
+		attr->ia_mtime = current_time(inode);
 		attr->ia_valid |= ATTR_MTIME_SET;
 	}
 
 	if (attr->ia_valid & (ATTR_MTIME | ATTR_CTIME))
-		CDEBUG(D_INODE, "setting mtime %lu, ctime %lu, now = %llu\n",
-		       LTIME_S(attr->ia_mtime), LTIME_S(attr->ia_ctime),
+		CDEBUG(D_INODE, "setting mtime %llu, ctime %llu, now = %llu\n",
+		       (long long)LTIME_S(attr->ia_mtime), (long long)LTIME_S(attr->ia_ctime),
 		       (s64)ktime_get_real_seconds());
 
 	/* We always do an MDS RPC, even if we're only changing the size;
@@ -1564,9 +1564,9 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 	}
 	if (body->valid & OBD_MD_FLMTIME) {
 		if (body->mtime > LTIME_S(inode->i_mtime)) {
-			CDEBUG(D_INODE, "setting ino %lu mtime from %lu to %llu\n",
-			       inode->i_ino, LTIME_S(inode->i_mtime),
-			       body->mtime);
+			CDEBUG(D_INODE, "setting ino %lu mtime from %llu to %llu\n",
+			       inode->i_ino, (unsigned long long)LTIME_S(inode->i_mtime),
+			       (unsigned long long)body->mtime);
 			LTIME_S(inode->i_mtime) = body->mtime;
 		}
 		lli->lli_mtime = body->mtime;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 5eba0eb..48ed1ce 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -731,8 +731,8 @@ static void ll_update_times(struct ptlrpc_request *request,
 	LASSERT(body);
 	if (body->valid & OBD_MD_FLMTIME &&
 	    body->mtime > LTIME_S(inode->i_mtime)) {
-		CDEBUG(D_INODE, "setting fid "DFID" mtime from %lu to %llu\n",
-		       PFID(ll_inode2fid(inode)), LTIME_S(inode->i_mtime),
+		CDEBUG(D_INODE, "setting fid "DFID" mtime from %llu to %llu\n",
+		       PFID(ll_inode2fid(inode)), (unsigned long long)LTIME_S(inode->i_mtime),
 		       body->mtime);
 		LTIME_S(inode->i_mtime) = body->mtime;
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 4ef3db1..9980f3a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -143,9 +143,9 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	rpc_lock = obd->u.cli.cl_rpc_lock;
 
 	if (op_data->op_attr.ia_valid & (ATTR_MTIME | ATTR_CTIME))
-		CDEBUG(D_INODE, "setting mtime %ld, ctime %ld\n",
-		       LTIME_S(op_data->op_attr.ia_mtime),
-		       LTIME_S(op_data->op_attr.ia_ctime));
+		CDEBUG(D_INODE, "setting mtime %lld, ctime %lld\n",
+		       (long long)LTIME_S(op_data->op_attr.ia_mtime),
+		       (long long)LTIME_S(op_data->op_attr.ia_ctime));
 	mdc_setattr_pack(req, op_data, ea, ealen, ea2, ea2len);
 
 	ptlrpc_request_set_replen(req);
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index b41b65e..ccd2b7b 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -54,9 +54,9 @@ void obdo_refresh_inode(struct inode *dst, struct obdo *src, u32 valid)
 
 	if (valid & (OBD_MD_FLCTIME | OBD_MD_FLMTIME))
 		CDEBUG(D_INODE,
-		       "valid %#llx, cur time %lu/%lu, new %llu/%llu\n",
-		       src->o_valid, LTIME_S(dst->i_mtime),
-		       LTIME_S(dst->i_ctime), src->o_mtime, src->o_ctime);
+		       "valid %#llx, cur time %llu/%llu, new %llu/%llu\n",
+		       src->o_valid, (unsigned long long)LTIME_S(dst->i_mtime),
+		       (unsigned long long)LTIME_S(dst->i_ctime), src->o_mtime, src->o_ctime);
 
 	if (valid & OBD_MD_FLATIME && src->o_atime > LTIME_S(dst->i_atime))
 		LTIME_S(dst->i_atime) = src->o_atime;
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 748e33f..973fa4c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -62,9 +62,9 @@ void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
 	u32 newvalid = 0;
 
 	if (valid & (OBD_MD_FLCTIME | OBD_MD_FLMTIME))
-		CDEBUG(D_INODE, "valid %x, new time %lu/%lu\n",
-		       valid, LTIME_S(src->i_mtime),
-		       LTIME_S(src->i_ctime));
+		CDEBUG(D_INODE, "valid %x, new time %llu/%llu\n",
+		       valid, (unsigned long long)LTIME_S(src->i_mtime),
+		       (unsigned long long)LTIME_S(src->i_ctime));
 
 	if (valid & OBD_MD_FLATIME) {
 		dst->o_atime = LTIME_S(src->i_atime);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index d534b0e..99f69bb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -221,7 +221,7 @@ static void osc_page_touch_at(const struct lu_env *env,
 	       kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms,
 	       loi->loi_lvb.lvb_size);
 
-	attr->cat_mtime = attr->cat_ctime = LTIME_S(CURRENT_TIME);
+	attr->cat_mtime = attr->cat_ctime = ktime_get_real_seconds();
 	valid = CAT_MTIME | CAT_CTIME;
 	if (kms > loi->loi_kms) {
 		attr->cat_kms = kms;
-- 
1.9.1
