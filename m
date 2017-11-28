From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 28 Nov 2017 16:51:08 +0300
Subject: [lustre-devel] [bug report] staging: lustre: remove unnecessary
 NULL checks in kernel_comm.c
Message-ID: <20171128135108.hedez7bglpdidkky@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Lustre devs,

Smatch generates this warning:

	drivers/staging/lustre/lustre/obdclass/kernelcomm.c:146 libcfs_kkuc_group_rem()
	error: buffer overflow 'kkuc_groups' 3 <= u32max

drivers/staging/lustre/lustre/obdclass/kernelcomm.c
   142  int libcfs_kkuc_group_rem(int uid, unsigned int group)
   143  {
   144          struct kkuc_reg *reg, *next;
   145  
   146          if (!kkuc_groups[group].next)
                                 ^^^^^
Basically the complaint is that Smatch thinks "group" comes from the
user and hasn't been checked@all.

   147                  return 0;
   148  
   149          if (!uid) {
   150                  /* Broadcast a shutdown message */
   151                  struct kuc_hdr lh;
   152  

Where "group" comes from is lmv_iocontrol() in lmv_obd.c:

drivers/staging/lustre/lustre/lmv/lmv_obd.c
  1078          case LL_IOC_HSM_CT_START: {
  1079                  struct lustre_kernelcomm *lk = karg;
                                                  ^^^^^^^^^
  1080  
  1081                  if (lk->lk_flags & LK_FLG_STOP)
  1082                          rc = lmv_hsm_ct_unregister(lmv, cmd, len, lk, uarg);
                                                                          ^^
We take "karg" from somewhere get lk->lk_group here.

  1083                  else
  1084                          rc = lmv_hsm_ct_register(lmv, cmd, len, lk, uarg);
  1085                  break;
  1086          }

The problem is that, in Lustre, instead of functions we just have
ioctls.  Sometimes lmv_iocontrol() is called with validated data and
sometimes it's called with untrusted data.  Often with these kinds of
things I could just print the call tree to see where it's set to user
data and audit those places, but in Lustre the ioctls just call
themselves recursively so the call tree doesn't help.

And what I hate the most is obd_iocontrol().  Everything goes through
obd_iocontrol()...  It would be hard to design something which makes the
code more opaque than obd_iocontrol().

The bottom line, is I have no idea if this warning is correct or not.

regards,
dan carpenter
