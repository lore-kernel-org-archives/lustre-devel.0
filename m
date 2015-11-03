From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 3 Nov 2015 23:28:17 +0000
Subject: [lustre-devel] [patch] staging: lustre: potential underflow in
 libcfs_kkuc_group_add()
In-Reply-To: <20151029135122.GA7709@mwanda>
References: <20151029135122.GA7709@mwanda>
Message-ID: <b7e8511d07d84cfaa9e437729795f179@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>My static checker says that "group" is a user controlled number that can
>be negative leading to an array underflow.  I have looked at it, and I'm
>not an expert enough in lustre to say for sure if it is really a bug.
>Anyway, it's simple enough to make the variable unsigned which pleases
>the static checker and makes it easier to audit.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Dmitry do you this this could be placed under place under LU-6303 or does a new ticket need to be open.
I also CC Frank Zago who is very familiar with this code. To me it looks okay.

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
index a989d26..41f3d81 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_kernelcomm.h
@@ -91,7 +91,7 @@ typedef int (*libcfs_kkuc_cb_t)(__u32 data, void *cb_arg);
 /* Kernel methods */
 int libcfs_kkuc_msg_put(struct file *fp, void *payload);
 int libcfs_kkuc_group_put(int group, void *payload);
-int libcfs_kkuc_group_add(struct file *fp, int uid, int group,
+int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
 				 __u32 data);
 int libcfs_kkuc_group_rem(int uid, int group);
 int libcfs_kkuc_group_foreach(int group, libcfs_kkuc_cb_t cb_func,
diff --git a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
index ad661a3..d8230ae 100644
--- a/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
+++ b/drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
@@ -110,7 +110,8 @@ static DECLARE_RWSEM(kg_sem);
  * @param uid identifier for this receiver
  * @param group group number
  */
-int libcfs_kkuc_group_add(struct file *filp, int uid, int group, __u32 data)
+int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
+			  __u32 data)
 {
 	struct kkuc_reg *reg;
 
_______________________________________________
devel mailing list
devel at linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
