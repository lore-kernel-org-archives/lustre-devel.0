From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:51 -0400
Subject: [lustre-devel] [PATCH 0/9] staging: lustre: bug fixes from the
	lustre 2.5.[54-55] release
Message-ID: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Here is the next batch of fixes and cleanups that went into
Lustre versions 2.5.54 and 2.5.55 except for the work done
for LU-3531. The changes for LU-3531 are large so they belong
in their own special patch set. Most of the patches here are
minor fixes and some removal of dead or obsolete code.

Alexander Boyko (1):
  staging: lustre: osc: Allow lock to be canceled at ENQ time

Andreas Dilger (1):
  staging: lustre: debug: clean up console messages

Bobi Jam (1):
  staging: lustre: nfs: don't panic NFS server if MDS fails to find FID

Fan Yong (1):
  staging: lustre: fid: packing ost_idx in IDIF

John L. Hammond (2):
  staging: lustre: lov: remove lov and lod stuff from obd.h
  staging: lustre: lov: remove unused lov obd functions

Niu Yawei (1):
  staging: lustre: ptlrpc: fix nrs cleanup

wang di (2):
  staging: lustre: mdt: extra checking for getattr RPC.
  staging: lustre: fid: init FID client for OSP on MDT.

 drivers/staging/lustre/lustre/fid/fid_request.c    |  7 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      | 76 +++++++++++++++-------
 drivers/staging/lustre/lustre/include/lustre_fid.h | 22 ++-----
 drivers/staging/lustre/lustre/include/obd.h        | 60 -----------------
 .../staging/lustre/lustre/include/obd_support.h    |  1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  6 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    | 13 ++--
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  5 --
 drivers/staging/lustre/lustre/lov/lov_internal.h   | 32 ++++-----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  3 -
 drivers/staging/lustre/lustre/lov/lov_pool.c       | 62 +-----------------
 drivers/staging/lustre/lustre/lov/lov_request.c    |  3 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  3 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  3 +
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  6 +-
 16 files changed, 101 insertions(+), 203 deletions(-)

--
2.7.4
