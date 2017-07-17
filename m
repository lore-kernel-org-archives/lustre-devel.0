From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 17 Jul 2017 11:18:57 +0530
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: constify
	attribute_group structures.
In-Reply-To: <1500270540-5928-1-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500270540-5928-1-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <1500270540-5928-2-git-send-email-arvind.yadav.cs@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: john.hammond@intel.com, dmitry.eremin@intel.com, fan.yong@intel.com

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/sysfs.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   9489	    992	     40	  10521	   2919	lustre/lustre/osc/lproc_osc.o
   1289	    288	      0	   1577	    629	lustre/lustre/lmv/lproc_lmv.o
   3794	    928	     40	   4762	   129a	lustre/lustre/lov/lproc_lov.o
   3802	    576	     40	   4418	   1142	lustre/lustre/mdc/lproc_mdc.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   9553	    928	     40	  10521	   2919	lustre/lustre/osc/lproc_osc.o
   1353	    224	      0	   1577	    629	lustre/lustre/lmv/lproc_lmv.o
   3858	    864	     40	   4762	   129a	lustre/lustre/lov/lproc_lov.o
   3866	    512	     40	   4418	   1142	lustre/lustre/mdc/lproc_mdc.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h | 4 ++--
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c          | 2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c          | 2 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c          | 2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c          | 2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 915283c..9054d37 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -59,7 +59,7 @@ struct lprocfs_vars {
 
 struct lprocfs_static_vars {
 	struct lprocfs_vars *obd_vars;
-	struct attribute_group *sysfs_vars;
+	const struct attribute_group *sysfs_vars;
 };
 
 /* if we find more consumers this could be generalized */
@@ -468,7 +468,7 @@ struct dentry *ldebugfs_register(const char *name,
 void ldebugfs_remove(struct dentry **entryp);
 
 int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
-		      struct attribute_group *attrs);
+		      const struct attribute_group *attrs);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
 int ldebugfs_seq_create(struct dentry *parent,
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index bf25f88..4c13e39 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -161,7 +161,7 @@ static int lmv_target_seq_open(struct inode *inode, struct file *file)
 	NULL,
 };
 
-static struct attribute_group lmv_attr_group = {
+static const struct attribute_group lmv_attr_group = {
 	.attrs = lmv_attrs,
 };
 
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index eb6d30d..ce46821 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -279,7 +279,7 @@ static int lov_target_seq_open(struct inode *inode, struct file *file)
 	NULL,
 };
 
-static struct attribute_group lov_attr_group = {
+static const struct attribute_group lov_attr_group = {
 	.attrs = lov_attrs,
 };
 
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 9021c46..9fea535 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -219,7 +219,7 @@ static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group mdc_attr_group = {
+static const struct attribute_group mdc_attr_group = {
 	.attrs = mdc_attrs,
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 86f252d..6e0fd15 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -831,7 +831,7 @@ int lproc_osc_attach_seqstat(struct obd_device *dev)
 	NULL,
 };
 
-static struct attribute_group osc_attr_group = {
+static const struct attribute_group osc_attr_group = {
 	.attrs = osc_attrs,
 };
 
-- 
1.9.1
