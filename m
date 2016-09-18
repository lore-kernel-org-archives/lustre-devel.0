From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:44 -0400
Subject: [lustre-devel] [PATCH 105/124] staging: lustre: clio: pass fid for
	OST setattr
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-106-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

Store inode's fid in cl_setattr_ost() and OSC packs this info on the
wire (via lustre_set_wire_obdo) so that OST can use.

NOTE: currently lu_fid::f_ver and obdo::o_parent_ver are not used on
OFD device, and we use obdo::o_stripe_idx as
filter_fid::ff_parent::f_ver and save it to the device.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1154
Reviewed-on: http://review.whamcloud.com/12902
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h |    2 ++
 drivers/staging/lustre/lustre/llite/lcommon_cl.c  |    1 +
 drivers/staging/lustre/lustre/lov/lov_io.c        |    3 +++
 drivers/staging/lustre/lustre/osc/osc_io.c        |    6 ++++--
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 9403c0c..89292c9 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1766,6 +1766,8 @@ struct cl_io {
 		struct cl_setattr_io {
 			struct ost_lvb   sa_attr;
 			unsigned int     sa_valid;
+			int		sa_stripe_index;
+			struct lu_fid  *sa_parent_fid;
 		} ci_setattr;
 		struct cl_fault_io {
 			/** page index within file. */
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 2ded6b5..084330d 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -99,6 +99,7 @@ int cl_setattr_ost(struct inode *inode, const struct iattr *attr)
 	io->u.ci_setattr.sa_attr.lvb_ctime = LTIME_S(attr->ia_ctime);
 	io->u.ci_setattr.sa_attr.lvb_size = attr->ia_size;
 	io->u.ci_setattr.sa_valid = attr->ia_valid;
+	io->u.ci_setattr.sa_parent_fid = ll_inode2fid(inode);
 
 again:
 	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 5d47a5a..d101579 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -87,6 +87,9 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 	case CIT_SETATTR: {
 		io->u.ci_setattr.sa_attr = parent->u.ci_setattr.sa_attr;
 		io->u.ci_setattr.sa_valid = parent->u.ci_setattr.sa_valid;
+		io->u.ci_setattr.sa_stripe_index = stripe;
+		io->u.ci_setattr.sa_parent_fid =
+					parent->u.ci_setattr.sa_parent_fid;
 		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 42e9761..8a559cb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -484,11 +484,13 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	memset(oa, 0, sizeof(*oa));
 	if (result == 0) {
 		oa->o_oi = loi->loi_oi;
+		obdo_set_parent_fid(oa, io->u.ci_setattr.sa_parent_fid);
+		oa->o_stripe_idx = io->u.ci_setattr.sa_stripe_index;
 		oa->o_mtime = attr->cat_mtime;
 		oa->o_atime = attr->cat_atime;
 		oa->o_ctime = attr->cat_ctime;
-		oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLATIME |
-			OBD_MD_FLCTIME | OBD_MD_FLMTIME;
+		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLATIME |
+			       OBD_MD_FLCTIME | OBD_MD_FLMTIME;
 		if (ia_valid & ATTR_SIZE) {
 			oa->o_size = size;
 			oa->o_blocks = OBD_OBJECT_EOF;
-- 
1.7.1
