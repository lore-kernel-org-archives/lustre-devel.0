From: Patrick Farrell <paf@cray.com>
Date: Mon, 21 May 2018 13:20:30 +0000
Subject: [lustre-devel] [PATCH 13/30] staging: lustre: replace
 libcfs_register_ioctl with a blocking notifier_chain
In-Reply-To: <152687731283.24196.5413466102459843186.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>,
 <152687731283.24196.5413466102459843186.stgit@noble>
Message-ID: <DM3PR1101MB12139C3BC443E61A476F95B5CB950@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Just going through these (thank you, Neal, for more excellent cleanup work), and this one stands out as one someone should look over a bit.  I can do it later if no one who's familiar with this wants to, but I wanted to highlight it.

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Sunday, May 20, 2018 11:35:12 PM
To: Oleg Drokin; Greg Kroah-Hartman; James Simmons; Andreas Dilger
Cc: Linux Kernel Mailing List; Lustre Development List
Subject: [lustre-devel] [PATCH 13/30] staging: lustre: replace libcfs_register_ioctl with a blocking notifier_chain

libcfs allows other modules to register handlers for ioctls.
The implementation it uses for this is nearly identical to a
blocking notifier chain, so change to use that.

The biggest difference is that the return value from notifier has a
defined format, where libcfs_register_ioctl uses -EINVAL to mean
"continue".  This requires a little bit of conversion.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   19 ++----
 drivers/staging/lustre/lnet/libcfs/module.c        |   64 ++++----------------
 drivers/staging/lustre/lnet/lnet/module.c          |   38 ++++++++----
 drivers/staging/lustre/lnet/selftest/conctl.c      |   27 +++++---
 drivers/staging/lustre/lnet/selftest/console.c     |   10 ++-
 drivers/staging/lustre/lnet/selftest/console.h     |    3 +
 6 files changed, 70 insertions(+), 91 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index d9002e7424d4..63ea0e99ec58 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -93,19 +93,14 @@
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023

-struct libcfs_ioctl_handler {
-       struct list_head item;
-       int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
-};
-
-#define DECLARE_IOCTL_HANDLER(ident, func)                     \
-       struct libcfs_ioctl_handler ident = {                   \
-               .item           = LIST_HEAD_INIT(ident.item),   \
-               .handle_ioctl   = func                          \
-       }
+extern struct blocking_notifier_head libcfs_ioctl_list;
+static inline int notifier_from_ioctl_errno(int err)
+{
+       if (err == -EINVAL)
+               return NOTIFY_OK;
+       return notifier_from_errno(err) | NOTIFY_STOP_MASK;
+}

-int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
-int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_setup(void);

 #define _LIBCFS_H
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 3e51aae751c5..b3a7c1a912ba 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -62,38 +62,8 @@

 static struct dentry *lnet_debugfs_root;

-static DECLARE_RWSEM(ioctl_list_sem);
-static LIST_HEAD(ioctl_list);
-
-int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand)
-{
-       int rc = 0;
-
-       down_write(&ioctl_list_sem);
-       if (!list_empty(&hand->item))
-               rc = -EBUSY;
-       else
-               list_add_tail(&hand->item, &ioctl_list);
-       up_write(&ioctl_list_sem);
-
-       return rc;
-}
-EXPORT_SYMBOL(libcfs_register_ioctl);
-
-int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
-{
-       int rc = 0;
-
-       down_write(&ioctl_list_sem);
-       if (list_empty(&hand->item))
-               rc = -ENOENT;
-       else
-               list_del_init(&hand->item);
-       up_write(&ioctl_list_sem);
-
-       return rc;
-}
-EXPORT_SYMBOL(libcfs_deregister_ioctl);
+BLOCKING_NOTIFIER_HEAD(libcfs_ioctl_list);
+EXPORT_SYMBOL(libcfs_ioctl_list);

 static inline size_t libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 {
@@ -268,24 +238,18 @@ static int libcfs_ioctl(unsigned long cmd, void __user *uparam)
                 libcfs_debug_mark_buffer(data->ioc_inlbuf1);
                 break;

-       default: {
-               struct libcfs_ioctl_handler *hand;
-
-               err = -EINVAL;
-               down_read(&ioctl_list_sem);
-               list_for_each_entry(hand, &ioctl_list, item) {
-                       err = hand->handle_ioctl(cmd, hdr);
-                       if (err == -EINVAL)
-                               continue;
-
-                       if (!err) {
-                               if (copy_to_user(uparam, hdr, hdr->ioc_len))
-                                       err = -EFAULT;
-                       }
-                       break;
-               }
-               up_read(&ioctl_list_sem);
-               break; }
+       default:
+               err = blocking_notifier_call_chain(&libcfs_ioctl_list,
+                                                  cmd, hdr);
+               if (!(err & NOTIFY_STOP_MASK))
+                       /* No-one claimed the ioctl */
+                       err = -EINVAL;
+               else
+                       err = notifier_to_errno(err);
+               if (!err)
+                       if (copy_to_user(uparam, hdr, hdr->ioc_len))
+                               err = -EFAULT;
+               break;
         }
 out:
         kvfree(hdr);
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index f6e912e79ca7..9d06664f0c17 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -136,30 +136,37 @@ lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
 }

 static int
-lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
+lnet_ioctl(struct notifier_block *nb,
+          unsigned long cmd, void *vdata)
 {
         int rc;
+       struct libcfs_ioctl_hdr *hdr = vdata;

         switch (cmd) {
         case IOC_LIBCFS_CONFIGURE: {
                 struct libcfs_ioctl_data *data =
                         (struct libcfs_ioctl_data *)hdr;

-               if (data->ioc_hdr.ioc_len < sizeof(*data))
-                       return -EINVAL;
-
-               the_lnet.ln_nis_from_mod_params = data->ioc_flags;
-               return lnet_configure(NULL);
+               if (data->ioc_hdr.ioc_len < sizeof(*data)) {
+                       rc = -EINVAL;
+               } else {
+                       the_lnet.ln_nis_from_mod_params = data->ioc_flags;
+                       rc = lnet_configure(NULL);
+               }
+               break;
         }

         case IOC_LIBCFS_UNCONFIGURE:
-               return lnet_unconfigure();
+               rc = lnet_unconfigure();
+               break;

         case IOC_LIBCFS_ADD_NET:
-               return lnet_dyn_configure(hdr);
+               rc = lnet_dyn_configure(hdr);
+               break;

         case IOC_LIBCFS_DEL_NET:
-               return lnet_dyn_unconfigure(hdr);
+               rc = lnet_dyn_unconfigure(hdr);
+               break;

         default:
                 /*
@@ -172,11 +179,14 @@ lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
                         rc = LNetCtl(cmd, hdr);
                         LNetNIFini();
                 }
-               return rc;
+               break;
         }
+       return notifier_from_ioctl_errno(rc);
 }

-static DECLARE_IOCTL_HANDLER(lnet_ioctl_handler, lnet_ioctl);
+static struct notifier_block lnet_ioctl_handler = {
+       .notifier_call = lnet_ioctl,
+};

 static int __init lnet_init(void)
 {
@@ -194,7 +204,8 @@ static int __init lnet_init(void)
                 return rc;
         }

-       rc = libcfs_register_ioctl(&lnet_ioctl_handler);
+       rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
+                                             &lnet_ioctl_handler);
         LASSERT(!rc);

         if (config_on_load) {
@@ -212,7 +223,8 @@ static void __exit lnet_exit(void)
 {
         int rc;

-       rc = libcfs_deregister_ioctl(&lnet_ioctl_handler);
+       rc = blocking_notifier_chain_unregister(&libcfs_ioctl_list,
+                                               &lnet_ioctl_handler);
         LASSERT(!rc);

         lnet_lib_exit();
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index a2d8092bdeb7..f22b01e390d3 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -680,32 +680,34 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 }

 int
-lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
+lstcon_ioctl_entry(struct notifier_block *nb,
+                  unsigned long cmd, void *vdata)
 {
-       char *buf;
+       struct libcfs_ioctl_hdr *hdr = vdata;
+       char *buf = NULL;
         struct libcfs_ioctl_data *data;
         int opc;
-       int rc;
+       int rc = -EINVAL;

         if (cmd != IOC_LIBCFS_LNETST)
-               return -EINVAL;
+               goto err;

         data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);

         opc = data->ioc_u32[0];

         if (data->ioc_plen1 > PAGE_SIZE)
-               return -EINVAL;
+               goto err;

         buf = kmalloc(data->ioc_plen1, GFP_KERNEL);
+       rc = -ENOMEM;
         if (!buf)
-               return -ENOMEM;
+               goto err;

         /* copy in parameter */
-       if (copy_from_user(buf, data->ioc_pbuf1, data->ioc_plen1)) {
-               kfree(buf);
-               return -EFAULT;
-       }
+       rc = -EFAULT;
+       if (copy_from_user(buf, data->ioc_pbuf1, data->ioc_plen1))
+               goto err;

         mutex_lock(&console_session.ses_mutex);

@@ -785,6 +787,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
                 break;
         default:
                 rc = -EINVAL;
+               goto out;
         }

         if (copy_to_user(data->ioc_pbuf2, &console_session.ses_trans_stat,
@@ -792,8 +795,8 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
                 rc = -EFAULT;
 out:
         mutex_unlock(&console_session.ses_mutex);
-
+err:
         kfree(buf);

-       return rc;
+       return notifier_from_ioctl_errno(rc);
 }
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1889f1e86473..9fd6013354c6 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1996,7 +1996,9 @@ static void lstcon_init_acceptor_service(void)
         lstcon_acceptor_service.sv_wi_total = SFW_FRWK_WI_MAX;
 }

-static DECLARE_IOCTL_HANDLER(lstcon_ioctl_handler, lstcon_ioctl_entry);
+static struct notifier_block lstcon_ioctl_handler = {
+       .notifier_call = lstcon_ioctl_entry,
+};

 /* initialize console */
 int
@@ -2048,7 +2050,8 @@ lstcon_console_init(void)
                 goto out;
         }

-       rc = libcfs_register_ioctl(&lstcon_ioctl_handler);
+       rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
+                                             &lstcon_ioctl_handler);

         if (!rc) {
                 lstcon_rpc_module_init();
@@ -2071,7 +2074,8 @@ lstcon_console_fini(void)
 {
         int i;

-       libcfs_deregister_ioctl(&lstcon_ioctl_handler);
+       blocking_notifier_chain_unregister(&libcfs_ioctl_list,
+                                          &lstcon_ioctl_handler);

         mutex_lock(&console_session.ses_mutex);

diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 3933ed4cca93..d65b8d942bac 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -187,7 +187,8 @@ lstcon_id2hash(struct lnet_process_id id, struct list_head *hash)
         return &hash[idx];
 }

-int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
+int lstcon_ioctl_entry(struct notifier_block *nb,
+                      unsigned long cmd, void *vdata);
 int lstcon_console_init(void);
 int lstcon_console_fini(void);
 int lstcon_session_match(struct lst_sid sid);


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180521/56c3a35f/attachment-0001.html>
