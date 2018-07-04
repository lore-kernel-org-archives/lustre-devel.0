From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 00/11] lustre cleanups following "lustre:
 missing updates from lustre 2.9"
Message-ID: <153067941050.30111.13691201276059352926.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This series covers all the issues that I found while reviewing
James' recent patch series names in $SUBJECT, except for
fixing the patch that I thought was broken.

In several cases the same issue that I saw in those patches was
already present elsewhere in the lustre code, and I cleaned
up all (or many) relevant occurrences.

Thanks,
NeilBrown

---

NeilBrown (11):
      lustre: use DIV_ROUND_UP() where appropriate.
      lustre: osc: don't take spinlock to read a "long"
      lustre: llite: replace several GFP_NOFS with GFP_KERNEL
      lustre: fix alignment in lustre_idl.h
      lustre: improve alignment in lustre_disk.h
      lustre: mdc: change memcpy to strcpy.
      lustre: simplify some parsing in lmd_parse().
      lustre: protect updates to ll_flags.
      lustre: remove dead code from obd_connect_flags2str()
      lustre: iput() accepts NULL.
      lustre: avoid alloc(sizeof(struct ...))


 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 1079 ++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    3 
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    4 
 drivers/staging/lustre/lnet/selftest/console.c     |    8 
 drivers/staging/lustre/lnet/selftest/framework.c   |    8 
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
 .../staging/lustre/lustre/include/lustre_disk.h    |   38 -
 drivers/staging/lustre/lustre/llite/dir.c          |    3 
 drivers/staging/lustre/lustre/llite/file.c         |   32 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    6 
 drivers/staging/lustre/lustre/llite/statahead.c    |    3 
 drivers/staging/lustre/lustre/llite/xattr.c        |    4 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 
 .../lustre/lustre/obdclass/lprocfs_status.c        |    7 
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   24 
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   36 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 
 20 files changed, 622 insertions(+), 648 deletions(-)

--
Signature
