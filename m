From: Patrick Farrell <paf@cray.com>
Date: Wed, 9 Dec 2015 22:00:03 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: add __user attributes
 to	llite/file.c
In-Reply-To: <1449606856-21619-1-git-send-email-nauxuron@wimdewith.com>
References: <1449606856-21619-1-git-send-email-nauxuron@wimdewith.com>
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614D3F419@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greg just recently replied to a similar patch rejecting it.  I don't have his response handy, but I bet you can find it in the archives.  Briefly, this hides possible errors rather than fixing them.
________________________________________
From: lustre-devel [lustre-devel-bounces at lists.lustre.org] on behalf of Wim de With [nauxuron at wimdewith.com]
Sent: Tuesday, December 08, 2015 2:34 PM
To: oleg.drokin at intel.com; andreas.dilger at intel.com; gregkh at linuxfoundation.org
Cc: devel at driverdev.osuosl.org; Wim de With; linux-kernel at vger.kernel.org; lustre-devel at lists.lustre.org
Subject: [lustre-devel] [PATCH] staging: lustre: add __user attributes to       llite/file.c

This fixes the following sparse warnings:

drivers/staging/lustre/lustre/llite/file.c:1310:38:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:1310:38:    got struct ll_recreate_obj *<noident>
drivers/staging/lustre/lustre/llite/file.c:1328:35: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1328:35:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:1328:35:    got struct lu_fid *<noident>
drivers/staging/lustre/lustre/llite/file.c:1475:35: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1475:35:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:1475:35:    got struct lov_user_md_v1 *<noident>
drivers/staging/lustre/lustre/llite/file.c:1500:35: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1500:35:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:1500:35:    got struct lov_user_md_v1 *lumv1p
drivers/staging/lustre/lustre/llite/file.c:1505:44: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1505:44:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:1505:44:    got struct lov_user_md_v3 *lumv3p
drivers/staging/lustre/lustre/llite/file.c:1516:17: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1516:17:    expected void const volatile [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:1516:17:    got unsigned short *<noident>
drivers/staging/lustre/lustre/llite/file.c:1829:27: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:1829:27:    expected void [noderef] <asn:1>*to
drivers/staging/lustre/lustre/llite/file.c:1829:27:    got void *<noident>
drivers/staging/lustre/lustre/llite/file.c:2214:24: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2214:24:    expected void const volatile [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2214:24:    got int *<noident>
drivers/staging/lustre/lustre/llite/file.c:2221:21: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2221:21:    expected void const volatile [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2221:21:    got int *<noident>
drivers/staging/lustre/lustre/llite/file.c:2245:43: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2245:43:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:2245:43:    got char *<noident>
drivers/staging/lustre/lustre/llite/file.c:2275:24: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2275:24:    expected void const volatile [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2275:24:    got int *<noident>
drivers/staging/lustre/lustre/llite/file.c:2292:35: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2292:35:    expected void [noderef] <asn:1>*to
drivers/staging/lustre/lustre/llite/file.c:2292:35:    got void *<noident>
drivers/staging/lustre/lustre/llite/file.c:2299:44: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2299:44:    expected void [noderef] <asn:1>*arg
drivers/staging/lustre/lustre/llite/file.c:2299:44:    got void *<noident>
drivers/staging/lustre/lustre/llite/file.c:2304:43: warning: incorrect type in argument 2 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2304:43:    expected void const [noderef] <asn:1>*from
drivers/staging/lustre/lustre/llite/file.c:2304:43:    got char *<noident>
drivers/staging/lustre/lustre/llite/file.c:2310:46: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2310:46:    expected void [noderef] <asn:1>*to
drivers/staging/lustre/lustre/llite/file.c:2310:46:    got char *<noident>
drivers/staging/lustre/lustre/llite/file.c:2323:21: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2323:21:    expected void const volatile [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2323:21:    got int *<noident>
drivers/staging/lustre/lustre/llite/file.c:2350:35: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2350:35:    expected void [noderef] <asn:1>*to
drivers/staging/lustre/lustre/llite/file.c:2350:35:    got void *<noident>
drivers/staging/lustre/lustre/llite/file.c:2361:36: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2361:36:    expected void const [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2361:36:    got char *<noident>
drivers/staging/lustre/lustre/llite/file.c:2389:35: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2389:35:    expected void [noderef] <asn:1>*to
drivers/staging/lustre/lustre/llite/file.c:2389:35:    got char *<noident>
drivers/staging/lustre/lustre/llite/file.c:2483:36: warning: incorrect type in argument 1 (different address spaces)
drivers/staging/lustre/lustre/llite/file.c:2483:36:    expected void const [noderef] <asn:1>*<noident>
drivers/staging/lustre/lustre/llite/file.c:2483:36:    got void *<noident>

It simply casts pointers to __user pointers in most cases, and changes a
few pointers to __user pointers.

Signed-off-by: Wim de With <nauxuron@wimdewith.com>
---
 drivers/staging/lustre/lustre/llite/file.c | 43 ++++++++++++++++--------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 02f2759..27fc7af 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1307,7 +1307,7 @@ static int ll_lov_recreate_obj(struct inode *inode, unsigned long arg)
        if (!capable(CFS_CAP_SYS_ADMIN))
                return -EPERM;

-       if (copy_from_user(&ucreat, (struct ll_recreate_obj *)arg,
+       if (copy_from_user(&ucreat, (struct ll_recreate_obj __user *)arg,
                           sizeof(ucreat)))
                return -EFAULT;

@@ -1325,7 +1325,7 @@ static int ll_lov_recreate_fid(struct inode *inode, unsigned long arg)
        if (!capable(CFS_CAP_SYS_ADMIN))
                return -EPERM;

-       if (copy_from_user(&fid, (struct lu_fid *)arg, sizeof(fid)))
+       if (copy_from_user(&fid, (struct lu_fid __user *)arg, sizeof(fid)))
                return -EFAULT;

        fid_to_ostid(&fid, &oi);
@@ -1472,7 +1472,7 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
        if (lump == NULL)
                return -ENOMEM;

-       if (copy_from_user(lump, (struct lov_user_md *)arg, lum_size)) {
+       if (copy_from_user(lump, (struct lov_user_md __user *)arg, lum_size)) {
                kvfree(lump);
                return -EFAULT;
        }
@@ -1490,8 +1490,10 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 {
        struct lov_user_md_v3    lumv3;
        struct lov_user_md_v1   *lumv1 = (struct lov_user_md_v1 *)&lumv3;
-       struct lov_user_md_v1   *lumv1p = (struct lov_user_md_v1 *)arg;
-       struct lov_user_md_v3   *lumv3p = (struct lov_user_md_v3 *)arg;
+       struct lov_user_md_v1 __user *lumv1p =
+               (struct lov_user_md_v1 __user *)arg;
+       struct lov_user_md_v3 __user *lumv3p =
+               (struct lov_user_md_v3 __user *)arg;
        int                      lum_size, rc;
        int                      flags = FMODE_WRITE;

@@ -1826,7 +1828,7 @@ static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
                ret_bytes += (fiemap_s->fm_mapped_extents *
                                 sizeof(struct ll_fiemap_extent));

-       if (copy_to_user((void *)arg, fiemap_s, ret_bytes))
+       if (copy_to_user((void __user *)arg, fiemap_s, ret_bytes))
                rc = -EFAULT;

 error:
@@ -2211,14 +2213,14 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
        switch (cmd) {
        case LL_IOC_GETFLAGS:
                /* Get the current value of the file flags */
-               return put_user(fd->fd_flags, (int *)arg);
+               return put_user(fd->fd_flags, (int __user *)arg);
        case LL_IOC_SETFLAGS:
        case LL_IOC_CLRFLAGS:
                /* Set or clear specific file flags */
                /* XXX This probably needs checks to ensure the flags are
                 *     not abused, and to handle any flag side effects.
                 */
-               if (get_user(flags, (int *) arg))
+               if (get_user(flags, (int __user *)arg))
                        return -EFAULT;

                if (cmd == LL_IOC_SETFLAGS) {
@@ -2242,8 +2244,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                struct file *file2;
                struct lustre_swap_layouts lsl;

-               if (copy_from_user(&lsl, (char *)arg,
-                                      sizeof(struct lustre_swap_layouts)))
+               if (copy_from_user(&lsl, (char __user *)arg,
+                                  sizeof(struct lustre_swap_layouts)))
                        return -EFAULT;

                if ((file->f_flags & O_ACCMODE) == 0) /* O_RDONLY */
@@ -2272,7 +2274,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                return ll_iocontrol(inode, file, cmd, arg);
        case FSFILT_IOC_GETVERSION_OLD:
        case FSFILT_IOC_GETVERSION:
-               return put_user(inode->i_generation, (int *)arg);
+               return put_user(inode->i_generation, (int __user *)arg);
        case LL_IOC_GROUP_LOCK:
                return ll_get_grouplock(inode, file, arg);
        case LL_IOC_GROUP_UNLOCK:
@@ -2289,25 +2291,26 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
        case LL_IOC_FLUSHCTX:
                return ll_flush_ctx(inode);
        case LL_IOC_PATH2FID: {
-               if (copy_to_user((void *)arg, ll_inode2fid(inode),
+               if (copy_to_user((void __user *)arg, ll_inode2fid(inode),
                                 sizeof(struct lu_fid)))
                        return -EFAULT;

                return 0;
        }
        case OBD_IOC_FID2PATH:
-               return ll_fid2path(inode, (void *)arg);
+               return ll_fid2path(inode, (void __user *)arg);
        case LL_IOC_DATA_VERSION: {
                struct ioc_data_version idv;
                int                     rc;

-               if (copy_from_user(&idv, (char *)arg, sizeof(idv)))
+               if (copy_from_user(&idv, (char __user *)arg, sizeof(idv)))
                        return -EFAULT;

                rc = ll_data_version(inode, &idv.idv_version,
                                !(idv.idv_flags & LL_DV_NOFLUSH));

-               if (rc == 0 && copy_to_user((char *) arg, &idv, sizeof(idv)))
+               if (rc == 0 && copy_to_user((char __user *)arg, &idv,
+                                           sizeof(idv)))
                        return -EFAULT;

                return rc;
@@ -2320,7 +2323,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                if (mdtidx < 0)
                        return mdtidx;

-               if (put_user((int)mdtidx, (int *)arg))
+               if (put_user((int)mdtidx, (int __user *)arg))
                        return -EFAULT;

                return 0;
@@ -2347,7 +2350,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                rc = obd_iocontrol(cmd, ll_i2mdexp(inode), sizeof(*op_data),
                                   op_data, NULL);

-               if (copy_to_user((void *)arg, hus, sizeof(*hus)))
+               if (copy_to_user((void __user *)arg, hus, sizeof(*hus)))
                        rc = -EFAULT;

                ll_finish_md_op_data(op_data);
@@ -2358,7 +2361,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                struct hsm_state_set    *hss;
                int                      rc;

-               hss = memdup_user((char *)arg, sizeof(*hss));
+               hss = memdup_user((char __user *)arg, sizeof(*hss));
                if (IS_ERR(hss))
                        return PTR_ERR(hss);

@@ -2386,7 +2389,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
                rc = obd_iocontrol(cmd, ll_i2mdexp(inode), sizeof(*op_data),
                                   op_data, NULL);

-               if (copy_to_user((char *)arg, hca, sizeof(*hca)))
+               if (copy_to_user((char __user *)arg, hca, sizeof(*hca)))
                        rc = -EFAULT;

                ll_finish_md_op_data(op_data);
@@ -2480,7 +2483,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
        case LL_IOC_HSM_IMPORT: {
                struct hsm_user_import *hui;

-               hui = memdup_user((void *)arg, sizeof(*hui));
+               hui = memdup_user((void __user *)arg, sizeof(*hui));
                if (IS_ERR(hui))
                        return PTR_ERR(hui);

--
2.6.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
