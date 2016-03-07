From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:19 -0500
Subject: [lustre-devel] [PATCH v2 4/9] staging: lustre: fix 'NULL pointer
	dereference' errors
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>

From: Sebastien Buisson <sbuisson@ddn.com>

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

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2217
Reviewed-on: http://review.whamcloud.com/4720
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +
 drivers/staging/lustre/lnet/selftest/conctl.c      |   49 ++++++++++----------
 .../lustre/lustre/include/lustre/lustre_user.h     |    3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    7 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   10 ++++-
 .../lustre/lustre/obdclass/lprocfs_status.c        |   24 +++++----
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 +-
 9 files changed, 61 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index b640db2..35422f8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -162,6 +162,7 @@ lnet_iov_nob(unsigned int niov, struct kvec *iov)
 {
 	unsigned int nob = 0;
 
+	LASSERT(!niov || iov);
 	while (niov-- > 0)
 		nob += (iov++)->iov_len;
 
@@ -282,6 +283,7 @@ lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
 {
 	unsigned int nob = 0;
 
+	LASSERT(!niov || kiov);
 	while (niov-- > 0)
 		nob += (kiov++)->kiov_len;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 714d14b..62cacb6 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -670,44 +670,45 @@ static int
 lst_stat_query_ioctl(lstio_stat_args_t *args)
 {
 	int rc;
-	char *name;
+	char *name = NULL;
 
 	/* TODO: not finished */
 	if (args->lstio_sta_key != console_session.ses_key)
 		return -EACCES;
 
-	if (!args->lstio_sta_resultp ||
-	    (!args->lstio_sta_namep && !args->lstio_sta_idsp) ||
-	    args->lstio_sta_nmlen <= 0 ||
-	    args->lstio_sta_nmlen > LST_NAME_SIZE)
-		return -EINVAL;
-
-	if (args->lstio_sta_idsp &&
-	    args->lstio_sta_count <= 0)
+	if (!args->lstio_sta_resultp)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
-	if (copy_from_user(name, args->lstio_sta_namep,
-			   args->lstio_sta_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
-		return -EFAULT;
-	}
+	if (args->lstio_sta_idsp) {
+		if (args->lstio_sta_count <= 0)
+			return -EINVAL;
 
-	if (!args->lstio_sta_idsp) {
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
 
-	LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
+		LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
+		if (!name)
+			return -ENOMEM;
 
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
 
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 9f026bd..276906e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -448,6 +448,9 @@ static inline void obd_str2uuid(struct obd_uuid *uuid, const char *tmp)
 /* For printf's only, make sure uuid is terminated */
 static inline char *obd_uuid2str(const struct obd_uuid *uuid)
 {
+	if (!uuid)
+		return NULL;
+
 	if (uuid->uuid[sizeof(*uuid) - 1] != '\0') {
 		/* Obviously not safe, but for printfs, no real harm done...
 		 * we're always null-terminated, even in a race.
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 2d501a6..6f0761c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -708,8 +708,13 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		if (policy)
 			lock->l_policy_data = *policy;
 
-		if (einfo->ei_type == LDLM_EXTENT)
+		if (einfo->ei_type == LDLM_EXTENT) {
+			/* extent lock without policy is a bug */
+			if (!policy)
+				LBUG();
+
 			lock->l_req_extent = policy->l_extent;
+		}
 		LDLM_DEBUG(lock, "client-side enqueue START, flags %llx\n",
 			   *flags);
 	}
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 5c055a0..267f001 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -238,7 +238,7 @@ static int lmv_connect(const struct lu_env *env,
 	 * and MDC stuff will be called directly, for instance while reading
 	 * ../mdc/../kbytesfree procfs file, etc.
 	 */
-	if (data->ocd_connect_flags & OBD_CONNECT_REAL)
+	if (data && data->ocd_connect_flags & OBD_CONNECT_REAL)
 		rc = lmv_check_connect(obd);
 
 	if (rc && lmv->lmv_tgts_kobj)
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 4f568f0..7178a02 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -178,7 +178,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 				   cfs_time_seconds(1), NULL, NULL);
 
 	rc = l_wait_event(waitq, lov_check_set(lov, ost_idx), &lwi);
-	if (tgt && tgt->ltd_active)
+	if (tgt->ltd_active)
 		return 1;
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index f5a85bb..bc49633 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -344,7 +344,15 @@ static int config_log_add(struct obd_device *obd, char *logname,
 	LASSERT(lsi->lsi_lmd);
 	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)) {
 		struct config_llog_data *recover_cld;
-		*strrchr(seclogname, '-') = 0;
+
+		ptr = strrchr(seclogname, '-');
+		if (ptr) {
+			*ptr = 0;
+		} else {
+			CERROR("sptlrpc log name not correct: %s", seclogname);
+			config_log_put(cld);
+			return -EINVAL;
+		}
 		recover_cld = config_recover_log_add(obd, seclogname, cfg, sb);
 		if (IS_ERR(recover_cld)) {
 			rc = PTR_ERR(recover_cld);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 7c28755..1ea1578 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1359,17 +1359,19 @@ int lprocfs_write_frac_u64_helper(const char __user *buffer,
 	}
 
 	units = 1;
-	switch (tolower(*end)) {
-	case 'p':
-		units <<= 10;
-	case 't':
-		units <<= 10;
-	case 'g':
-		units <<= 10;
-	case 'm':
-		units <<= 10;
-	case 'k':
-		units <<= 10;
+	if (end) {
+		switch (tolower(*end)) {
+		case 'p':
+			units <<= 10;
+		case 't':
+			units <<= 10;
+		case 'g':
+			units <<= 10;
+		case 'm':
+			units <<= 10;
+		case 'k':
+			units <<= 10;
+		}
 	}
 	/* Specified units override the multiplier */
 	if (units > 1)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index bdd9053..5b06901 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1798,7 +1798,7 @@ swabber_dumper_helper(struct req_capsule *pill,
 			return;
 		swabber(value);
 		ptlrpc_buf_set_swabbed(pill->rc_req, inout, offset);
-		if (dump) {
+		if (dump && field->rmf_dumper) {
 			CDEBUG(D_RPCTRACE, "Dump of swabbed field %s follows\n",
 			       field->rmf_name);
 			field->rmf_dumper(value);
-- 
1.7.1
