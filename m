From: NeilBrown <neilb@suse.com>
Date: Mon, 07 May 2018 10:54:47 +1000
Subject: [lustre-devel] [PATCH 00/10 - v2] staging: lustre: assorted
 improvements.
Message-ID: <152565436690.30131.2229703651041382739.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This v2 series contains some fixes for issue found
during review - particularly the share/exclusive locking
confusion of the hash table in one place, and a missing
EXPORT_SYMPOL.  It also adds some reviewed-by tags.

original intro:

First 6 patches are clean-up patches that I pulled out
of my rhashtable series.  I think these stand alone as
good cleanups, and having them upstream makes the rhashtable
series shorter to ease further review.

Second 2 are revised versions of patches I sent previously that
had conflicts with other patches that landed first.

Last is a bugfix for an issue James mentioned a while back.

Thanks,
NeilBrown


---

NeilBrown (10):
      staging: lustre: ldlm: store name directly in namespace.
      staging: lustre: make struct lu_site_bkt_data private
      staging: lustre: lu_object: discard extra lru count.
      staging: lustre: lu_object: move retry logic inside htable_lookup
      staging: lustre: fold lu_object_new() into lu_object_find_at()
      staging: lustre: llite: use more private data in dump_pgcache
      staging: lustre: llite: remove redundant lookup in dump_pgcache
      staging: lustre: move misc-device registration closer to related code.
      staging: lustre: move remaining code from linux-module.c to module.c
      staging: lustre: fix error deref in ll_splice_alias().


 .../staging/lustre/include/linux/libcfs/libcfs.h   |    6 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    1 
 .../lustre/lnet/libcfs/linux/linux-module.c        |  196 --------------------
 drivers/staging/lustre/lnet/libcfs/module.c        |  161 ++++++++++++++++
 drivers/staging/lustre/lustre/include/lu_object.h  |   36 ----
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    5 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    5 +
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    8 -
 drivers/staging/lustre/lustre/llite/namei.c        |    9 +
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  166 +++++++----------
 drivers/staging/lustre/lustre/lov/lov_object.c     |    8 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  174 +++++++++---------
 12 files changed, 346 insertions(+), 429 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c

--
Signature
