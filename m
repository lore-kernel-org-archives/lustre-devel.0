From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:07 -0700
Subject: [lustre-devel] [PATCH 09/12] lustre: Replace CURRENT_TIME macro
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-10-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

CURRENT_TIME macro is not y2038 safe on 32 bit systems.

The patch replaces all the uses of CURRENT_TIME by
current_time() for filesystem times, and ktime_get_*
functions for others.

struct timespec is also not y2038 safe.
Retain timespec for timestamp representation here as lustre
uses it internally everywhere.
These references will be changed to use struct timespec64
in a separate patch.

This is also in preparation for the patch that transitions
vfs timestamps to use 64 bit time and hence make them
y2038 safe. current_time() is also planned to be transitioned
to y2038 safe behavior along with this change.

CURRENT_TIME macro will be deleted before merging the
aforementioned change.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 6 +++---
 drivers/staging/lustre/lustre/osc/osc_io.c      | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7b80040..2b4b6b9 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1472,17 +1472,17 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 
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
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index f991bee..cbab800 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -216,7 +216,7 @@ static int osc_io_submit(const struct lu_env *env,
 		struct cl_object *obj = ios->cis_obj;
 
 		cl_object_attr_lock(obj);
-		attr->cat_mtime = LTIME_S(CURRENT_TIME);
+		attr->cat_mtime = ktime_get_real_seconds();
 		attr->cat_ctime = attr->cat_mtime;
 		cl_object_attr_update(env, obj, attr, CAT_MTIME | CAT_CTIME);
 		cl_object_attr_unlock(obj);
@@ -256,7 +256,7 @@ static void osc_page_touch_at(const struct lu_env *env,
 	       kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms,
 	       loi->loi_lvb.lvb_size);
 
-	attr->cat_ctime = LTIME_S(CURRENT_TIME);
+	attr->cat_ctime = ktime_get_real_seconds();
 	attr->cat_mtime = attr->cat_ctime;
 	valid = CAT_MTIME | CAT_CTIME;
 	if (kms > loi->loi_kms) {
-- 
2.7.4
