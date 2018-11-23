From: NeilBrown <neilb@suse.com>
Date: Fri, 23 Nov 2018 18:15:27 +1100
Subject: [lustre-devel] [PATCH 0/9] Assorted lustre patches - mostly from
 OpenSFS
Message-ID: <154295730810.2850.961218355189474016.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is a miscellaneous set of patches for lustre-in-linux.
Apart from the first, they are (bases on) patches from OpenSFS lustre.
I've been trawling through OpenSFS looking for patches that aren't
in linux-lustre.  Most of what I find are only relevant on the
server, but these seem to be appropriate for the client.
In most cases, I don't really know what is going on, so they
might be inappropriate for the client.  I'm hoping that more
knowledgeable people can put be straight.

This are just the first few - I think there are quite a few more
(before we get to e.g. pfl which has been attempted yet).  If
I've got these mostly right, I'll continue looking through
the rest of my list.

Thanks,
NeilBrown

---

Bruno Faccini (2):
      lustre: llite: clear LLIF_FILE_RESTORING when done
      lustre: obdclass: health_check to report unhealthy upon LBUG

Doug Oucharek (1):
      lustre: lnet: Stop MLX5 triggering a dump_cqe

Fan Yong (1):
      lustre: statahead: skip agl for the file in restoring

James Simmons (1):
      lustre: remove EIOCBRETRY handling

Lai Siyao (2):
      lustre: rename: DNE2 should return -EXDEV upon remote rename
      lustre: statahead: add smp_mb() to serialize ops

NeilBrown (1):
      lustre: obdclass: fix formating of connection flags

Vladimir Saveliev (1):
      lustre: ptlrpc: use smp unsafe at_init only for initialization


 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    7 ++++-
 .../staging/lustre/lustre/include/lustre_errno.h   |    1 -
 .../staging/lustre/lustre/include/lustre_import.h  |   19 ++++++++++++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 ++++
 drivers/staging/lustre/lustre/llite/statahead.c    |   28 ++++++++++++++++++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |    4 +--
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    4 ++-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    2 +
 9 files changed, 61 insertions(+), 12 deletions(-)

--
Signature
