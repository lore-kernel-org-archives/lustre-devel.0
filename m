From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:13:55 -0500
Subject: [lustre-devel] [PATCH v2 00/33] lustre: add PFL support
Message-ID: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Progressive file layouts are characterized by increasing the
stripe count of the file in a step-wise manner as the file
offset increases. This will be achieved by using multiple
extent-based composite layouts as described in the Layout
Enhancement High Level Design:

http://wiki.lustre.org/Layout_Enhancement_High_Level_Design

This was the key item still missing in the linux lustre client.
We added this funcitonality with this patch set. With this last
key feature added this brings the linux lustre client on about
the same level as the 2.10.6 LTS. Since this is the case we can
bump the lustre version.

Andreas Dilger (1):
  lustre: lov: use stripe_count instead of stripe_nr

Bobi Jam (20):
  lustre: lov: move code for PFL work
  lustre: lov: merge lov_mds_md_v3 and lov_mds_md_v1 handling
  lustre: lov: fold lmm_verify() handling into lmm_unpackmd()
  lustre: lov: create struct lov_stripe_md_entry
  lustre: lov: add composite layout unpacking
  lustre: lov: embedded raid0 in struct lov_layout_composite
  lustre: lov: migrate lov raid0 to future PFL component handling
  lustre: lov: reduce code indentation
  lustre: lov: change lo_entries to array.
  lustre: lov: move around PFL code and cleanups
  lustre: lov: remove lsm_stripe_by_[index|offset]_plain
  lustre: lov: add looping lsm_entry_count times
  lustre: lov: create lov_comp_* wrappers
  lustre: clio: client side implementation for PFL
  lustre: pfl: dynamic layout modification with write/truncate
  lustre: pfl: calculate PFL file LOVEA correctly
  lustre: lov: keep minimum LOVEA size
  lustre: pfl: fix hang with grouplocks
  lustre: pfl: fix ost pool op->size handling
  lustre: llite: restore ll_file_getstripe in ll_lov_setstripe

Fan Yong (1):
  lustre: pfl: enhance PFID EA for PFL

James Simmons (2):
  lustre: clio: fix incorrect invariant in cl_io_iter_fini()
  lustre: update version to 2.9.99

Jinshan Xiong (3):
  lustre: pfl: Read should not trigger layout write intent
  lustre: lov: readahead shouldn't exceed component boundary
  lustre: lov: do not split IO for single striped file

Mike Pershin (1):
  lustre: lov: call cl_object_attr_get under cl_attr lock

Niu Yawei (4):
  lustre: pfl: Basic data structures for composite layout
  lustre: clio: getstripe support comp layout
  lustre: uapi: support negative flags
  lustre: llite: return v1/v3 layout for legacy app

wang di (1):
  lustre: ldlm: Transfer layout only if layout lock is granted

 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  36 +-
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  84 ++-
 .../lustre/include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  12 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h |   4 +-
 .../staging/lustre/lustre/include/lustre_swab.h    |   1 +
 drivers/staging/lustre/lustre/include/obd.h        |   4 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  18 -
 drivers/staging/lustre/lustre/llite/dir.c          |  38 +-
 drivers/staging/lustre/lustre/llite/file.c         | 200 +++--
 .../staging/lustre/lustre/llite/llite_internal.h   |   3 +
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  44 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  70 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    | 191 ++---
 drivers/staging/lustre/lustre/lov/lov_ea.c         | 570 ++++++++++----
 drivers/staging/lustre/lustre/lov/lov_internal.h   | 177 +++--
 drivers/staging/lustre/lustre/lov/lov_io.c         | 651 +++++++++-------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  94 ++-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |  12 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 833 ++++++++++++---------
 drivers/staging/lustre/lustre/lov/lov_offset.c     |  65 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       | 368 +++++----
 drivers/staging/lustre/lustre/lov/lov_page.c       |  42 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  20 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |   4 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  23 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  89 ++-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   5 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  16 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   7 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   6 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  84 ++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |   7 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 125 +++-
 37 files changed, 2507 insertions(+), 1411 deletions(-)

-- 
1.8.3.1
