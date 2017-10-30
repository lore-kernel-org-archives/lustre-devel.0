From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 00/10] staging: lustre: assorted code
 improvements for list manipulations.
Message-ID: <150933945578.22133.8029060522107378499.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

There are mostly conversions of list_for_each() to
list_for_each_entry() and similar.  list_first_entry()
also makes a few appearances.

Thanks,
NeilBrown


---

NeilBrown (10):
      staging: lustre: use list_last_entry to simplify fld_cache_shrink
      staging: lustre: ldlm: use list_for_each_entry in ldlm_extent_shift_kms()
      staging: lustre: ldlm: use list_first_entry in ldlm_lock
      staging: lustre: ldlm: use list_for_each_entry in ldlm_lock.c
      staging: lustre: ldlm: use list_first_entry in ldlm_lockd.c
      staging: lustre: ldlm: minor list_entry improvements in ldlm_request.c
      staging: lustre: ldlm: use list_for_each_entry in ldlm_resource.c
      staging: lustre: lov: use list_for_each_entry in lov_obd.c
      staging: lustre: simplfy lov_finish_set()
      staging: lustre: obdclass: simplify cl_lock_fini()


 drivers/staging/lustre/lustre/fld/fld_cache.c      |   13 ++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 +---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   18 +++++++-----------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   10 +++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   12 ++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   20 +++++++-------------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    6 ++----
 drivers/staging/lustre/lustre/lov/lov_request.c    |   10 ++++------
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    9 ++++-----
 9 files changed, 40 insertions(+), 62 deletions(-)

--
Signature
