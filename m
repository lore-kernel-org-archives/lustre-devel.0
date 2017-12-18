From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 05/15] staging: lustre: lnet: selftest: don't
 allocate small strings.
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799039.6200.3383435277341826480.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

All of the "name" buffers here are at most LST_NAME_SIZE+1
bytes, so 33 bytes at most.
They are only used temporarily during the life of the function
that allocates them.
So it is much simpler to just allocate on the stack.
Worst case is lst_tet_add_ioct(), which allocates
3 for these which 99 bytes on the stack, instead of the 24 that would
have been allocated for 64-bit pointers.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/selftest/conctl.c |  180 ++++---------------------
 1 file changed, 29 insertions(+), 151 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 082c0afacf23..442a18ddd41f 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -45,7 +45,7 @@
 static int
 lst_session_new_ioctl(struct lstio_session_new_args *args)
 {
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 	int rc;
 
 	if (!args->lstio_ses_idp ||	/* address for output sid */
@@ -55,13 +55,8 @@ lst_session_new_ioctl(struct lstio_session_new_args *args)
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_ses_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_ses_namep,
 			   args->lstio_ses_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_ses_nmlen + 1);
 		return -EFAULT;
 	}
 
@@ -74,7 +69,6 @@ lst_session_new_ioctl(struct lstio_session_new_args *args)
 				args->lstio_ses_force,
 				args->lstio_ses_idp);
 
-	LIBCFS_FREE(name, args->lstio_ses_nmlen + 1);
 	return rc;
 }
 
@@ -112,7 +106,7 @@ lst_session_info_ioctl(struct lstio_session_info_args *args)
 static int
 lst_debug_ioctl(struct lstio_debug_args *args)
 {
-	char *name = NULL;
+	char name[LST_NAME_SIZE + 1];
 	int client = 1;
 	int rc;
 
@@ -128,16 +122,10 @@ lst_debug_ioctl(struct lstio_debug_args *args)
 		return -EINVAL;
 
 	if (args->lstio_dbg_namep) {
-		LIBCFS_ALLOC(name, args->lstio_dbg_nmlen + 1);
-		if (!name)
-			return -ENOMEM;
 
 		if (copy_from_user(name, args->lstio_dbg_namep,
-				   args->lstio_dbg_nmlen)) {
-			LIBCFS_FREE(name, args->lstio_dbg_nmlen + 1);
-
+				   args->lstio_dbg_nmlen))
 			return -EFAULT;
-		}
 
 		name[args->lstio_dbg_nmlen] = 0;
 	}
@@ -154,7 +142,7 @@ lst_debug_ioctl(struct lstio_debug_args *args)
 		client = 0;
 		/* fall through */
 	case LST_OPC_BATCHCLI:
-		if (!name)
+		if (!args->lstio_dbg_namep)
 			goto out;
 
 		rc = lstcon_batch_debug(args->lstio_dbg_timeout,
@@ -162,7 +150,7 @@ lst_debug_ioctl(struct lstio_debug_args *args)
 		break;
 
 	case LST_OPC_GROUP:
-		if (!name)
+		if (!args->lstio_dbg_namep)
 			goto out;
 
 		rc = lstcon_group_debug(args->lstio_dbg_timeout,
@@ -185,16 +173,13 @@ lst_debug_ioctl(struct lstio_debug_args *args)
 	}
 
 out:
-	if (name)
-		LIBCFS_FREE(name, args->lstio_dbg_nmlen + 1);
-
 	return rc;
 }
 
 static int
 lst_group_add_ioctl(struct lstio_group_add_args *args)
 {
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 	int rc;
 
 	if (args->lstio_grp_key != console_session.ses_key)
@@ -205,22 +190,14 @@ lst_group_add_ioctl(struct lstio_group_add_args *args)
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_grp_nmlen);
+			   args->lstio_grp_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_grp_nmlen] = 0;
 
 	rc = lstcon_group_add(name);
 
-	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-
 	return rc;
 }
 
@@ -228,7 +205,7 @@ static int
 lst_group_del_ioctl(struct lstio_group_del_args *args)
 {
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -238,22 +215,14 @@ lst_group_del_ioctl(struct lstio_group_del_args *args)
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
+			   args->lstio_grp_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_grp_nmlen] = 0;
 
 	rc = lstcon_group_del(name);
 
-	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-
 	return rc;
 }
 
@@ -261,7 +230,7 @@ static int
 lst_group_update_ioctl(struct lstio_group_update_args *args)
 {
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -272,15 +241,9 @@ lst_group_update_ioctl(struct lstio_group_update_args *args)
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
+			   args->lstio_grp_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_grp_nmlen] = 0;
 
@@ -309,8 +272,6 @@ lst_group_update_ioctl(struct lstio_group_update_args *args)
 		break;
 	}
 
-	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-
 	return rc;
 }
 
@@ -319,7 +280,7 @@ lst_nodes_add_ioctl(struct lstio_group_nodes_args *args)
 {
 	unsigned int feats;
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -333,16 +294,9 @@ lst_nodes_add_ioctl(struct lstio_group_nodes_args *args)
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-
+			   args->lstio_grp_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_grp_nmlen] = 0;
 
@@ -350,7 +304,6 @@ lst_nodes_add_ioctl(struct lstio_group_nodes_args *args)
 			      args->lstio_grp_idsp, &feats,
 			      args->lstio_grp_resultp);
 
-	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 	if (!rc &&
 	    copy_to_user(args->lstio_grp_featp, &feats, sizeof(feats))) {
 		return -EINVAL;
@@ -379,7 +332,7 @@ lst_group_list_ioctl(struct lstio_group_list_args *args)
 static int
 lst_group_info_ioctl(struct lstio_group_info_args *args)
 {
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 	int ndent;
 	int index;
 	int rc;
@@ -411,23 +364,15 @@ lst_group_info_ioctl(struct lstio_group_info_args *args)
 			return -EINVAL;
 	}
 
-	LIBCFS_ALLOC(name, args->lstio_grp_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_grp_namep,
-			   args->lstio_grp_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
+			   args->lstio_grp_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_grp_nmlen] = 0;
 
 	rc = lstcon_group_info(name, args->lstio_grp_entp,
 			       &index, &ndent, args->lstio_grp_dentsp);
 
-	LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
-
 	if (rc)
 		return rc;
 
@@ -443,7 +388,7 @@ static int
 lst_batch_add_ioctl(struct lstio_batch_add_args *args)
 {
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
@@ -453,22 +398,14 @@ lst_batch_add_ioctl(struct lstio_batch_add_args *args)
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_bat_namep,
-			   args->lstio_bat_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
+			   args->lstio_bat_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
 	rc = lstcon_batch_add(name);
 
-	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
-
 	return rc;
 }
 
@@ -476,7 +413,7 @@ static int
 lst_batch_run_ioctl(struct lstio_batch_run_args *args)
 {
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
@@ -486,23 +423,15 @@ lst_batch_run_ioctl(struct lstio_batch_run_args *args)
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_bat_namep,
-			   args->lstio_bat_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
+			   args->lstio_bat_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
 	rc = lstcon_batch_run(name, args->lstio_bat_timeout,
 			      args->lstio_bat_resultp);
 
-	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
-
 	return rc;
 }
 
@@ -510,7 +439,7 @@ static int
 lst_batch_stop_ioctl(struct lstio_batch_stop_args *args)
 {
 	int rc;
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
@@ -521,30 +450,22 @@ lst_batch_stop_ioctl(struct lstio_batch_stop_args *args)
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_bat_namep,
-			   args->lstio_bat_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
+			   args->lstio_bat_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
 	rc = lstcon_batch_stop(name, args->lstio_bat_force,
 			       args->lstio_bat_resultp);
 
-	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
-
 	return rc;
 }
 
 static int
 lst_batch_query_ioctl(struct lstio_batch_query_args *args)
 {
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 	int rc;
 
 	if (args->lstio_bat_key != console_session.ses_key)
@@ -559,15 +480,9 @@ lst_batch_query_ioctl(struct lstio_batch_query_args *args)
 	if (args->lstio_bat_testidx < 0)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_bat_namep,
-			   args->lstio_bat_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
+			   args->lstio_bat_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
@@ -577,8 +492,6 @@ lst_batch_query_ioctl(struct lstio_batch_query_args *args)
 				     args->lstio_bat_timeout,
 				     args->lstio_bat_resultp);
 
-	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
-
 	return rc;
 }
 
@@ -602,7 +515,7 @@ lst_batch_list_ioctl(struct lstio_batch_list_args *args)
 static int
 lst_batch_info_ioctl(struct lstio_batch_info_args *args)
 {
-	char *name;
+	char name[LST_NAME_SIZE + 1];
 	int rc;
 	int index;
 	int ndent;
@@ -634,15 +547,9 @@ lst_batch_info_ioctl(struct lstio_batch_info_args *args)
 			return -EINVAL;
 	}
 
-	LIBCFS_ALLOC(name, args->lstio_bat_nmlen + 1);
-	if (!name)
-		return -ENOMEM;
-
 	if (copy_from_user(name, args->lstio_bat_namep,
-			   args->lstio_bat_nmlen)) {
-		LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
+			   args->lstio_bat_nmlen))
 		return -EFAULT;
-	}
 
 	name[args->lstio_bat_nmlen] = 0;
 
@@ -650,8 +557,6 @@ lst_batch_info_ioctl(struct lstio_batch_info_args *args)
 			       args->lstio_bat_server, args->lstio_bat_testidx,
 			       &index, &ndent, args->lstio_bat_dentsp);
 
-	LIBCFS_FREE(name, args->lstio_bat_nmlen + 1);
-
 	if (rc)
 		return rc;
 
@@ -667,7 +572,7 @@ static int
 lst_stat_query_ioctl(struct lstio_stat_args *args)
 {
 	int rc;
-	char *name = NULL;
+	char name[LST_NAME_SIZE + 1];
 
 	/* TODO: not finished */
 	if (args->lstio_sta_key != console_session.ses_key)
@@ -689,10 +594,6 @@ lst_stat_query_ioctl(struct lstio_stat_args *args)
 		    args->lstio_sta_nmlen > LST_NAME_SIZE)
 			return -EINVAL;
 
-		LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
-		if (!name)
-			return -ENOMEM;
-
 		rc = copy_from_user(name, args->lstio_sta_namep,
 				    args->lstio_sta_nmlen);
 		if (!rc)
@@ -704,16 +605,14 @@ lst_stat_query_ioctl(struct lstio_stat_args *args)
 		rc = -EINVAL;
 	}
 
-	if (name)
-		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
 	return rc;
 }
 
 static int lst_test_add_ioctl(struct lstio_test_args *args)
 {
-	char *batch_name;
-	char *src_name = NULL;
-	char *dst_name = NULL;
+	char batch_name[LST_NAME_SIZE + 1];
+	char src_name[LST_NAME_SIZE + 1];
+	char dst_name[LST_NAME_SIZE + 1];
 	void *param = NULL;
 	int ret = 0;
 	int rc = -ENOMEM;
@@ -748,18 +647,6 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 	if (!args->lstio_tes_param && args->lstio_tes_param_len)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
-	if (!batch_name)
-		return rc;
-
-	LIBCFS_ALLOC(src_name, args->lstio_tes_sgrp_nmlen + 1);
-	if (!src_name)
-		goto out;
-
-	LIBCFS_ALLOC(dst_name, args->lstio_tes_dgrp_nmlen + 1);
-	if (!dst_name)
-		goto out;
-
 	if (args->lstio_tes_param) {
 		LIBCFS_ALLOC(param, args->lstio_tes_param_len);
 		if (!param)
@@ -791,15 +678,6 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 		rc = (copy_to_user(args->lstio_tes_retp, &ret,
 				   sizeof(ret))) ? -EFAULT : 0;
 out:
-	if (batch_name)
-		LIBCFS_FREE(batch_name, args->lstio_tes_bat_nmlen + 1);
-
-	if (src_name)
-		LIBCFS_FREE(src_name, args->lstio_tes_sgrp_nmlen + 1);
-
-	if (dst_name)
-		LIBCFS_FREE(dst_name, args->lstio_tes_dgrp_nmlen + 1);
-
 	if (param)
 		LIBCFS_FREE(param, args->lstio_tes_param_len);
 
