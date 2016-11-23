From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 Nov 2016 17:59:46 -0500
Subject: [lustre-devel] [PATCH 0/5] staging: lustre: ldlm: remove ldlm
	typedef usage from code
Message-ID: <1479941991-30059-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Replace usage of ldlm_policy_data_t, ldlm_wire_policy_t, ldlm_side_t
with named enums to conform to upstream coding style.

Fix users of flags that were using "int" instead of named enum.
Rename some "flags" variables to distinguish between different flags.

Rename LDLM_CANCEL_* flags (used with enum ldlm_lru_flags) to
LDLM_LRU_FLAGS_* to avoid confusion with enum ldlm_cancel_flags.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: http://review.whamcloud.com/15300
Reviewed-on: http://review.whamcloud.com/15301
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>

Andreas Dilger (5):
  staging: lustre: ldlm: remove ldlm_policy_data_t typedef usage from code
  staging: lustre: ldlm: remove ldlm_side_t typedef usage from code
  staging: lustre: ldlm: remove ldlm_wire_policy_data_t typedef usage from code
  staging: lustre: ldlm: rename LDLM_CANCEL_* flags
  staging: lustre: ldlm: change "int" to proper enum type

 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   44 +++++-----
 drivers/staging/lustre/lustre/include/obd.h        |    6 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    8 +-
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |    8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   85 ++++++++++----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   33 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |    8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   13 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   50 ++++++------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   22 +++---
 drivers/staging/lustre/lustre/llite/file.c         |   10 ++-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   11 ++-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   26 +++---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    5 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    6 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |    3 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    4 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 +-
 29 files changed, 200 insertions(+), 187 deletions(-)
