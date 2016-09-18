From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:06 -0400
Subject: [lustre-devel] [PATCH 067/124] staging: lustre: changelog: fix
	comparison between signed and unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-68-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change type of changelog_*{namelen,size}() to size_t.
Fixed string specifier for unsigned types.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12474
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Nunez <james.a.nunez@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |   10 +++++-----
 drivers/staging/lustre/lustre/llite/file.c         |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index de52339..e8f81a5 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -819,9 +819,9 @@ struct changelog_ext_jobid {
 	char	cr_jobid[LUSTRE_JOBID_SIZE];	/**< zero-terminated string. */
 };
 
-static inline unsigned int changelog_rec_offset(enum changelog_rec_flags crf)
+static inline size_t changelog_rec_offset(enum changelog_rec_flags crf)
 {
-	unsigned int size = sizeof(struct changelog_rec);
+	size_t size = sizeof(struct changelog_rec);
 
 	if (crf & CLF_RENAME)
 		size += sizeof(struct changelog_ext_rename);
@@ -832,12 +832,12 @@ static inline unsigned int changelog_rec_offset(enum changelog_rec_flags crf)
 	return size;
 }
 
-static inline int changelog_rec_size(struct changelog_rec *rec)
+static inline size_t changelog_rec_size(struct changelog_rec *rec)
 {
 	return changelog_rec_offset(rec->cr_flags);
 }
 
-static inline unsigned int changelog_rec_varsize(struct changelog_rec *rec)
+static inline size_t changelog_rec_varsize(struct changelog_rec *rec)
 {
 	return changelog_rec_size(rec) - sizeof(*rec) + rec->cr_namelen;
 }
@@ -869,7 +869,7 @@ static inline char *changelog_rec_name(struct changelog_rec *rec)
 						  CLF_SUPPORTED);
 }
 
-static inline int changelog_rec_snamelen(struct changelog_rec *rec)
+static inline size_t changelog_rec_snamelen(struct changelog_rec *rec)
 {
 	return rec->cr_namelen - strlen(changelog_rec_name(rec)) - 1;
 }
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 4b10260..a562b11 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1129,7 +1129,7 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 	struct cl_io	 *io;
 	ssize_t	       result;
 
-	CDEBUG(D_VFSTRACE, "file: %s, type: %d ppos: %llu, count: %zd\n",
+	CDEBUG(D_VFSTRACE, "file: %s, type: %d ppos: %llu, count: %zu\n",
 	       file->f_path.dentry->d_name.name, iot, *ppos, count);
 
 restart:
@@ -1207,7 +1207,7 @@ out:
 	 * short read/write instead of restart io.
 	 */
 	if ((result == 0 || result == -ENODATA) && io->ci_need_restart) {
-		CDEBUG(D_VFSTRACE, "Restart %s on %pD from %lld, count:%zd\n",
+		CDEBUG(D_VFSTRACE, "Restart %s on %pD from %lld, count:%zu\n",
 		       iot == CIT_READ ? "read" : "write",
 		       file, *ppos, count);
 		LASSERTF(io->ci_nob == 0, "%zd\n", io->ci_nob);
-- 
1.7.1
