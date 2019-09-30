From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:19 -0400
Subject: [lustre-devel] [PATCH 060/151] lustre: lov: allow lov.*.stripe{size,
 count}=-1 param
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Both the lov stripecount and stripeoffset sysfs files allows
the value of "-1". Setting it to "-1" to indicate that
the filesystem-wide default value should be used. Update the
ld_default_* setting to the proper signed type.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9611
Lustre-commit: f93276d9a5b5 ("LU-9611 lov: allow lov.*.stripe{size,count}=-1 param")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/27946
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lproc_lov.c              | 2 +-
 fs/lustre/obdclass/obd_config.c        | 6 +++---
 include/uapi/linux/lustre/lustre_idl.h | 6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lproc_lov.c b/fs/lustre/lov/lproc_lov.c
index cfb2744..4fecd4e 100644
--- a/fs/lustre/lov/lproc_lov.c
+++ b/fs/lustre/lov/lproc_lov.c
@@ -75,7 +75,7 @@ static ssize_t stripeoffset_show(struct kobject *kobj, struct attribute *attr,
 					      obd_kset.kobj);
 	struct lov_desc *desc = &dev->u.lov.desc;
 
-	return sprintf(buf, "%llu\n", desc->ld_default_stripe_offset);
+	return sprintf(buf, "%lld\n", desc->ld_default_stripe_offset);
 }
 
 static ssize_t stripeoffset_store(struct kobject *kobj, struct attribute *attr,
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 26b3e01..1485cc7 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1226,14 +1226,14 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			/* rc = -EINVAL;	continue parsing other params */
 			skip++;
 		} else if (rc < 0) {
-			CERROR("%s: error writing proc entry '%s': rc = %d\n",
+			CERROR("%s: error writing parameter '%s': rc = %d\n",
 			       prefix, var->name, rc);
 			rc = 0;
 		} else {
-			CDEBUG(D_CONFIG, "%s.%.*s: Set parameter %.*s=%s\n",
+			CDEBUG(D_CONFIG, "%s.%.*s: set parameter %.*s\n",
 			       lustre_cfg_string(lcfg, 0),
 			       (int)strlen(prefix) - 1, prefix,
-			       (int)(sval - key - 1), key, sval);
+			       (int)(sval - key - 1), key);
 		}
 	}
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2b585b6..2181386 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2035,10 +2035,10 @@ enum fld_op {
 struct lov_desc {
 	__u32 ld_tgt_count;		/* how many OBD's */
 	__u32 ld_active_tgt_count;	/* how many active */
-	__u32 ld_default_stripe_count;  /* how many objects are used */
+	__s32 ld_default_stripe_count;	/* how many objects are used */
 	__u32 ld_pattern;		/* default PATTERN_RAID0 */
-	__u64 ld_default_stripe_size;   /* in bytes */
-	__u64 ld_default_stripe_offset; /* in bytes */
+	__u64 ld_default_stripe_size;	/* in bytes */
+	__s64 ld_default_stripe_offset;	/* starting OST index */
 	__u32 ld_padding_0;		/* unused */
 	__u32 ld_qos_maxage;		/* in second */
 	__u32 ld_padding_1;		/* also fix lustre_swab_lov_desc */
-- 
1.8.3.1
