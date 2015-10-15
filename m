From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 15 Oct 2015 13:59:43 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
Message-ID: <20151015105943.GA22833@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Lustre Devs,

The patch d7e09d0397e8: "staging: add Lustre file system client
support" from May 2, 2013, leads to the following static checker
warning:

	drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c:150 libcfs_kkuc_group_rem()
	error: buffer overflow 'kkuc_groups' 3 <= s32max

drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c
   146  int libcfs_kkuc_group_rem(int uid, int group)
   147  {
   148          struct kkuc_reg *reg, *next;
   149  
   150          if (kkuc_groups[group].next == NULL)

group doesn't appear to have been validated@all.  It comes from the
user.  The call tree is:

-> lmv_iocontrol()
   -> lmv_hsm_ct_unregister()
      -> libcfs_kkuc_group_rem()

It looks like this code could oops.

   151                  return 0;
   152  
   153          if (uid == 0) {
   154                  /* Broadcast a shutdown message */
   155                  struct kuc_hdr lh;
   156  
   157                  lh.kuc_magic = KUC_MAGIC;
   158                  lh.kuc_transport = KUC_TRANSPORT_GENERIC;
   159                  lh.kuc_msgtype = KUC_MSG_SHUTDOWN;
   160                  lh.kuc_msglen = sizeof(lh);
   161                  libcfs_kkuc_group_put(group, &lh);
   162          }
   163  
   164          down_write(&kg_sem);
   165          list_for_each_entry_safe(reg, next, &kkuc_groups[group], kr_chain) {
   166                  if ((uid == 0) || (uid == reg->kr_uid)) {
   167                          list_del(&reg->kr_chain);
   168                          CDEBUG(D_KUC, "Removed uid=%d fp=%p from group %d\n",
   169                                 reg->kr_uid, reg->kr_fp, group);
   170                          if (reg->kr_fp != NULL)
   171                                  fput(reg->kr_fp);
   172                          kfree(reg);
   173                  }
   174          }
   175          up_write(&kg_sem);
   176  
   177          return 0;
   178  }

regards,
dan carpenter
