From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 00/13] Assorted lustre clean-ups
Message-ID: <151313493380.27582.16490205348451477393.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This series includes a resend of some "list_entry" cleanup
patches which now how better commit comments, and also
includes some simplifications, removing unnecessary macros
and code.

Thanks,
NeilBrown

---

NeilBrown (12):
      staging: lustre: use list_last_entry to simplify fld_cache_shrink
      staging: lustre: ldlm: use list_for_each_entry in ldlm_extent_shift_kms()
      staging: lustre: ldlm: use list_first_entry in ldlm_lockd.c
      staging: lustre: ldlm: minor list_entry improvements in ldlm_request.c
      staging: lustre: ldlm: use list_for_each_entry in ldlm_resource.c
      staging: lustre: lov: use list_for_each_entry in lov_obd.c
      staging: lustre: libcfs: simplify memory allocation.
      staging: lustre: libcfs: remove unused rounding functions.
      staging: lustre: libcfs: discard MKSTR() macro
      staging: lustre: libcfs: discard MAX_NUMERIC_VALUE
      staging: lustre: libcfs: discard KLASSERT()
      staging: lustre: libcfs: discard LASSERT_CHECKED


 .../lustre/include/linux/libcfs/libcfs_private.h   |   91 +++-----------------
 drivers/staging/lustre/lustre/fld/fld_cache.c      |   13 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   10 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   12 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   20 ++--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    6 -
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    4 -
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 
 9 files changed, 41 insertions(+), 121 deletions(-)

--
Signature
