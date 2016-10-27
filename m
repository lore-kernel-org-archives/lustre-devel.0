From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:34 -0400
Subject: [lustre-devel] [PATCH 00/29] Batch one for work from 2.7.55 to
	2.7.59
Message-ID: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The first two patches are fixes for problems pointed out by
Dan Carpenter and Julia LaWall. Batch of fixes from the Lustre 2.8
version. Basic support for selinux which before this work
prevented lustre from running. First patch to cleanup lustre_idl.h
which is a uapi header. All these patches are independent of
each other so they can be applied in any order.

Alex Zhuravlev (1):
  staging: lustre: ptlrpc: imp_peer_committed_transno should increase

Amir Shehata (1):
  staging: lustre: ptlrpc: Introduce iovec to bulk descriptor

Andreas Dilger (1):
  staging: lustre: obdclass: variable llog chunk size

Ben Evans (1):
  staging: lustre: headers: Create single .h for lu_seq_range

Bobi Jam (2):
  staging: lustre: llite: restart short read/write for normal IO
  staging: lustre: clio: update file attributes after sync

Gregoire Pichon (2):
  staging: lustre: ptlrpc: embed highest XID in each request
  staging: lustre: mdc: manage number of modify RPCs in flight

Henri Doreau (2):
  staging: lustre: ptlrpc: Forbid too early NRS policy tunings
  staging: lustre: llite: Inform copytool of dataversion changes

Hiroya Nozaki (1):
  staging: lustre: obdclass: race lustre_profile_list

Hongchao Zhang (1):
  staging: lustre: mdt: disable IMA support

James Simmons (2):
  staging: lustre: osc: remove handling cl_avail_grant less than zero
  staging: lustre: llite: remove IS_ERR(master_inode) check

John L. Hammond (2):
  staging: lustre: lov: remove LSM from struct lustre_md
  staging: lustre: llite: add LL_IOC_FUTIMES_3

Lai Siyao (1):
  staging: lustre: dne: setdirstripe should fail if not supported

Niu Yawei (3):
  staging: lustre: ldlm: reclaim granted locks defensively
  staging: lustre: recovery: don't skip open replay on reconnect
  staging: lustre: obdecho: don't copy lu_site

Sebastien Buisson (3):
  staging: lustre: llite: basic support of SELinux in CLIO
  staging: lustre: ptlrpc: do not sleep if encpool reached max capacity
  staging: lustre: ptlrpc: do not switch out-of-date context

wang di (6):
  staging: lustre: lmv: allow cross-MDT rename and link
  staging: lustre: llite: report back to user bad stripe count
  staging: lustre: ptlrpc: Do not resend req with allow_replay
  staging: lustre: mdc: deactive MDT permanently
  staging: lustre: ptlrpc: replay bulk request
  staging: lustre: llog: record the minimum record size

 .../lustre/include/linux/libcfs/libcfs_hash.h      |    2 +-
 drivers/staging/lustre/lnet/libcfs/fail.c          |    1 +
 drivers/staging/lustre/lnet/libcfs/hash.c          |   24 ++-
 drivers/staging/lustre/lustre/fid/fid_request.c    |   18 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |    6 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |    2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  154 ++++------------
 .../lustre/lustre/include/lustre/lustre_user.h     |   10 +
 drivers/staging/lustre/lustre/include/lustre_fid.h |    1 +
 drivers/staging/lustre/lustre/include/lustre_log.h |    6 +
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   24 +++
 drivers/staging/lustre/lustre/include/lustre_net.h |  161 +++++++++++++---
 drivers/staging/lustre/lustre/include/lustre_sec.h |    2 +
 drivers/staging/lustre/lustre/include/obd.h        |    9 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    9 +
 .../staging/lustre/lustre/include/obd_support.h    |    2 +
 drivers/staging/lustre/lustre/include/seq_range.h  |  199 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   37 ++++
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    8 +-
 drivers/staging/lustre/lustre/llite/Makefile       |    6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   31 +++-
 drivers/staging/lustre/lustre/llite/file.c         |  115 ++++++++----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   19 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   14 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   19 ++-
 drivers/staging/lustre/lustre/llite/xattr.c        |   65 +++----
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    4 +
 .../staging/lustre/lustre/llite/xattr_security.c   |   88 +++++++++
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   78 ++++++--
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    9 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   15 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |  120 +++++++-----
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  100 ++++------
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   60 ++++++
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   28 ++--
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   23 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   77 +++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    8 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  171 +++++++++++++++++-
 drivers/staging/lustre/lustre/obdclass/llog.c      |   49 +++--
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    1 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    8 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |   57 +++++-
 .../staging/lustre/lustre/obdecho/echo_client.c    |   20 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    3 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   38 +++--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  199 ++++++++++++++++----
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |   20 ++-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   16 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |    9 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   15 ++
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   31 ++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    9 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   12 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    7 +
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   48 ++++--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   20 +-
 65 files changed, 1649 insertions(+), 661 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/seq_range.h
 create mode 100644 drivers/staging/lustre/lustre/llite/xattr_security.c
