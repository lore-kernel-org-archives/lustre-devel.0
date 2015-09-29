From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:58 -0400
Subject: [lustre-devel] [PATCH 15/29] staging/lustre/obdclass: Drop unused
	code from obdo.c
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These functions are not even referenced in any header files anymore.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/obdo.c | 170 --------------------------
 1 file changed, 170 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 307ffe3..1a950fb 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -115,90 +115,6 @@ void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
 }
 EXPORT_SYMBOL(obdo_from_inode);
 
-void obdo_cpy_md(struct obdo *dst, struct obdo *src, u32 valid)
-{
-	CDEBUG(D_INODE, "src obdo "DOSTID" valid %#llx, dst obdo "DOSTID"\n",
-	       POSTID(&src->o_oi), src->o_valid, POSTID(&dst->o_oi));
-	if (valid & OBD_MD_FLATIME)
-		dst->o_atime = src->o_atime;
-	if (valid & OBD_MD_FLMTIME)
-		dst->o_mtime = src->o_mtime;
-	if (valid & OBD_MD_FLCTIME)
-		dst->o_ctime = src->o_ctime;
-	if (valid & OBD_MD_FLSIZE)
-		dst->o_size = src->o_size;
-	if (valid & OBD_MD_FLBLOCKS) /* allocation of space */
-		dst->o_blocks = src->o_blocks;
-	if (valid & OBD_MD_FLBLKSZ)
-		dst->o_blksize = src->o_blksize;
-	if (valid & OBD_MD_FLTYPE)
-		dst->o_mode = (dst->o_mode & ~S_IFMT) | (src->o_mode & S_IFMT);
-	if (valid & OBD_MD_FLMODE)
-		dst->o_mode = (dst->o_mode & S_IFMT) | (src->o_mode & ~S_IFMT);
-	if (valid & OBD_MD_FLUID)
-		dst->o_uid = src->o_uid;
-	if (valid & OBD_MD_FLGID)
-		dst->o_gid = src->o_gid;
-	if (valid & OBD_MD_FLFLAGS)
-		dst->o_flags = src->o_flags;
-	if (valid & OBD_MD_FLFID) {
-		dst->o_parent_seq = src->o_parent_seq;
-		dst->o_parent_ver = src->o_parent_ver;
-	}
-	if (valid & OBD_MD_FLGENER)
-		dst->o_parent_oid = src->o_parent_oid;
-	if (valid & OBD_MD_FLHANDLE)
-		dst->o_handle = src->o_handle;
-	if (valid & OBD_MD_FLCOOKIE)
-		dst->o_lcookie = src->o_lcookie;
-
-	dst->o_valid |= valid;
-}
-EXPORT_SYMBOL(obdo_cpy_md);
-
-/* returns FALSE if comparison (by flags) is same, TRUE if changed */
-int obdo_cmp_md(struct obdo *dst, struct obdo *src, u32 compare)
-{
-	int res = 0;
-
-	if (compare & OBD_MD_FLATIME)
-		res |= dst->o_atime != src->o_atime;
-	if (compare & OBD_MD_FLMTIME)
-		res |= dst->o_mtime != src->o_mtime;
-	if (compare & OBD_MD_FLCTIME)
-		res |= dst->o_ctime != src->o_ctime;
-	if (compare & OBD_MD_FLSIZE)
-		res |= dst->o_size != src->o_size;
-	if (compare & OBD_MD_FLBLOCKS) /* allocation of space */
-		res |= dst->o_blocks != src->o_blocks;
-	if (compare & OBD_MD_FLBLKSZ)
-		res |= dst->o_blksize != src->o_blksize;
-	if (compare & OBD_MD_FLTYPE)
-		res |= ((dst->o_mode ^ src->o_mode) & S_IFMT) != 0;
-	if (compare & OBD_MD_FLMODE)
-		res |= ((dst->o_mode ^ src->o_mode) & ~S_IFMT) != 0;
-	if (compare & OBD_MD_FLUID)
-		res |= dst->o_uid != src->o_uid;
-	if (compare & OBD_MD_FLGID)
-		res |= dst->o_gid != src->o_gid;
-	if (compare & OBD_MD_FLFLAGS)
-		res |= dst->o_flags != src->o_flags;
-	if (compare & OBD_MD_FLNLINK)
-		res |= dst->o_nlink != src->o_nlink;
-	if (compare & OBD_MD_FLFID) {
-		res |= dst->o_parent_seq != src->o_parent_seq;
-		res |= dst->o_parent_ver != src->o_parent_ver;
-	}
-	if (compare & OBD_MD_FLGENER)
-		res |= dst->o_parent_oid != src->o_parent_oid;
-	/* XXX Don't know if these should be included here - wasn't previously
-	if ( compare & OBD_MD_FLINLINE )
-		res |= memcmp(dst->o_inline, src->o_inline);
-	*/
-	return res;
-}
-EXPORT_SYMBOL(obdo_cmp_md);
-
 void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj)
 {
 	ioobj->ioo_oid = oa->o_oi;
@@ -211,42 +127,6 @@ void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj)
 }
 EXPORT_SYMBOL(obdo_to_ioobj);
 
-void obdo_from_iattr(struct obdo *oa, struct iattr *attr, unsigned int ia_valid)
-{
-	if (ia_valid & ATTR_ATIME) {
-		oa->o_atime = LTIME_S(attr->ia_atime);
-		oa->o_valid |= OBD_MD_FLATIME;
-	}
-	if (ia_valid & ATTR_MTIME) {
-		oa->o_mtime = LTIME_S(attr->ia_mtime);
-		oa->o_valid |= OBD_MD_FLMTIME;
-	}
-	if (ia_valid & ATTR_CTIME) {
-		oa->o_ctime = LTIME_S(attr->ia_ctime);
-		oa->o_valid |= OBD_MD_FLCTIME;
-	}
-	if (ia_valid & ATTR_SIZE) {
-		oa->o_size = attr->ia_size;
-		oa->o_valid |= OBD_MD_FLSIZE;
-	}
-	if (ia_valid & ATTR_MODE) {
-		oa->o_mode = attr->ia_mode;
-		oa->o_valid |= OBD_MD_FLTYPE | OBD_MD_FLMODE;
-		if (!in_group_p(make_kgid(&init_user_ns, oa->o_gid)) &&
-		    !capable(CFS_CAP_FSETID))
-			oa->o_mode &= ~S_ISGID;
-	}
-	if (ia_valid & ATTR_UID) {
-		oa->o_uid = from_kuid(&init_user_ns, attr->ia_uid);
-		oa->o_valid |= OBD_MD_FLUID;
-	}
-	if (ia_valid & ATTR_GID) {
-		oa->o_gid = from_kgid(&init_user_ns, attr->ia_gid);
-		oa->o_valid |= OBD_MD_FLGID;
-	}
-}
-EXPORT_SYMBOL(obdo_from_iattr);
-
 void iattr_from_obdo(struct iattr *attr, struct obdo *oa, u32 valid)
 {
 	valid &= oa->o_valid;
@@ -310,53 +190,3 @@ void md_from_obdo(struct md_op_data *op_data, struct obdo *oa, u32 valid)
 	}
 }
 EXPORT_SYMBOL(md_from_obdo);
-
-void obdo_from_md(struct obdo *oa, struct md_op_data *op_data,
-		  unsigned int valid)
-{
-	obdo_from_iattr(oa, &op_data->op_attr, valid);
-	if (valid & ATTR_BLOCKS) {
-		oa->o_blocks = op_data->op_attr_blocks;
-		oa->o_valid |= OBD_MD_FLBLOCKS;
-	}
-	if (valid & ATTR_ATTR_FLAG) {
-		oa->o_flags =
-			((struct ll_iattr *)&op_data->op_attr)->ia_attr_flags;
-		oa->o_valid |= OBD_MD_FLFLAGS;
-	}
-}
-EXPORT_SYMBOL(obdo_from_md);
-
-void obdo_cpu_to_le(struct obdo *dobdo, struct obdo *sobdo)
-{
-	dobdo->o_size = cpu_to_le64(sobdo->o_size);
-	dobdo->o_mtime = cpu_to_le64(sobdo->o_mtime);
-	dobdo->o_atime = cpu_to_le64(sobdo->o_atime);
-	dobdo->o_ctime = cpu_to_le64(sobdo->o_ctime);
-	dobdo->o_blocks = cpu_to_le64(sobdo->o_blocks);
-	dobdo->o_mode = cpu_to_le32(sobdo->o_mode);
-	dobdo->o_uid = cpu_to_le32(sobdo->o_uid);
-	dobdo->o_gid = cpu_to_le32(sobdo->o_gid);
-	dobdo->o_flags = cpu_to_le32(sobdo->o_flags);
-	dobdo->o_nlink = cpu_to_le32(sobdo->o_nlink);
-	dobdo->o_blksize = cpu_to_le32(sobdo->o_blksize);
-	dobdo->o_valid = cpu_to_le64(sobdo->o_valid);
-}
-EXPORT_SYMBOL(obdo_cpu_to_le);
-
-void obdo_le_to_cpu(struct obdo *dobdo, struct obdo *sobdo)
-{
-	dobdo->o_size = le64_to_cpu(sobdo->o_size);
-	dobdo->o_mtime = le64_to_cpu(sobdo->o_mtime);
-	dobdo->o_atime = le64_to_cpu(sobdo->o_atime);
-	dobdo->o_ctime = le64_to_cpu(sobdo->o_ctime);
-	dobdo->o_blocks = le64_to_cpu(sobdo->o_blocks);
-	dobdo->o_mode = le32_to_cpu(sobdo->o_mode);
-	dobdo->o_uid = le32_to_cpu(sobdo->o_uid);
-	dobdo->o_gid = le32_to_cpu(sobdo->o_gid);
-	dobdo->o_flags = le32_to_cpu(sobdo->o_flags);
-	dobdo->o_nlink = le32_to_cpu(sobdo->o_nlink);
-	dobdo->o_blksize = le32_to_cpu(sobdo->o_blksize);
-	dobdo->o_valid = le64_to_cpu(sobdo->o_valid);
-}
-EXPORT_SYMBOL(obdo_le_to_cpu);
-- 
2.1.0
