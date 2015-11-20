From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:38 -0500
Subject: [lustre-devel] [PATCH 02/40] staging: lustre: fix 'NULL pointer
	dereference' errors for LNet
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sebastien.buisson@bull.net>

Fix 'NULL pointer dereference' defects found by Coverity version
6.5.3:
Dereference after null check (FORWARD_NULL)
For instance, Passing null pointer to a function which dereferences
it.
Dereference before null check (REVERSE_INULL)
Null-checking variable suggests that it may be null, but it has
already been dereferenced on all paths leading to the check.
Dereference null return value (NULL_RETURNS)

The following fixes for the LNet layer are broken out of patch
http://review.whamcloud.com/4720.

Signed-off-by: Sebastien Buisson <sebastien.buisson@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2217
Reviewed-on: http://review.whamcloud.com/4720
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +
 drivers/staging/lustre/lnet/selftest/conctl.c      |   51 ++++++++++----------
 3 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index de0f85f..0f4154c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2829,7 +2829,7 @@ int kiblnd_startup(lnet_ni_t *ni)
 	return 0;
 
 failed:
-	if (net->ibn_dev == NULL && ibdev != NULL)
+	if (net && net->ibn_dev == NULL && ibdev != NULL)
 		kiblnd_destroy_dev(ibdev);
 
 net_failed:
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 5631f60..7a68382 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -162,6 +162,7 @@ lnet_iov_nob(unsigned int niov, struct kvec *iov)
 {
 	unsigned int nob = 0;
 
+	LASSERT(niov == 0 || iov);
 	while (niov-- > 0)
 		nob += (iov++)->iov_len;
 
@@ -280,6 +281,7 @@ lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
 {
 	unsigned int nob = 0;
 
+	LASSERT(niov == 0 || kiov);
 	while (niov-- > 0)
 		nob += (kiov++)->kiov_len;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 556c837..2ca7d0e 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -679,45 +679,46 @@ static int
 lst_stat_query_ioctl(lstio_stat_args_t *args)
 {
 	int rc;
-	char *name;
+	char *name = NULL;
 
 	/* TODO: not finished */
 	if (args->lstio_sta_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_sta_resultp == NULL ||
-	    (args->lstio_sta_namep  == NULL &&
-	     args->lstio_sta_idsp   == NULL) ||
-	    args->lstio_sta_nmlen <= 0 ||
-	    args->lstio_sta_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	if (args->lstio_sta_idsp != NULL &&
-	    args->lstio_sta_count <= 0)
+	if (!args->lstio_sta_resultp)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
-	if (name == NULL)
-		return -ENOMEM;
-
-	if (copy_from_user(name, args->lstio_sta_namep,
-			       args->lstio_sta_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
-		return -EFAULT;
-	}
+	if (args->lstio_sta_idsp) {
+		if (args->lstio_sta_count <= 0)
+			return -EINVAL;
 
-	if (args->lstio_sta_idsp == NULL) {
-		rc = lstcon_group_stat(name, args->lstio_sta_timeout,
-				       args->lstio_sta_resultp);
-	} else {
 		rc = lstcon_nodes_stat(args->lstio_sta_count,
 				       args->lstio_sta_idsp,
 				       args->lstio_sta_timeout,
 				       args->lstio_sta_resultp);
-	}
+	} else if (args->lstio_sta_namep) {
+		if (args->lstio_sta_nmlen <= 0 ||
+		    args->lstio_sta_nmlen > LST_NAME_SIZE)
+			return -EINVAL;
+
+		LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
+		if (!name)
+			return -ENOMEM;
 
-	LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
+		rc = copy_from_user(name, args->lstio_sta_namep,
+				    args->lstio_sta_nmlen);
+		if (!rc)
+			rc = lstcon_group_stat(name, args->lstio_sta_timeout,
+					       args->lstio_sta_resultp);
+		else
+			rc = -EFAULT;
 
+	} else {
+		rc = -EINVAL;
+	}
+
+	if (name)
+		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
 	return rc;
 }
 
-- 
1.7.1
