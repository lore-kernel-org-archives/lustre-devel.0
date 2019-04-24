From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Apr 2019 12:17:26 +1000
Subject: [lustre-devel] [PATCH 0/4] Update lustre in drivers/staging to
 5.1-rc1
Message-ID: <155607223991.16863.3231709121984405156.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I updated my tree to 5.1 some time ago, but didn't test it properly.
I've now tested and hunted down some obscure issues.
These 4 patches are needed to resolve issues caused by
the update.

The last two are most interesting.  selinux_is_enabled() is gone.  I
think the replacement code is correct, but I'm no expert on selinux.
More significantly, VM_FAULT_RETRY is no longer a #define, so
we are redefining it to zero, which is bad.

NeilBrown

---

NeilBrown (4):
      lustre: stop using deprecated wrappers.
      lustre: update for SO_RCVTIMEO SO_SNDTIMEO changes.
      lustre: remove use of selinux_is_enabled().
      lustre: don't define VM_FAULT_RETRY or FMODE_EXEC


 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    4 ++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   14 ++++++++++----
 .../staging/lustre/lustre/llite/llite_internal.h   |    8 --------
 drivers/staging/lustre/lustre/llite/xattr.c        |   11 -----------
 .../staging/lustre/lustre/llite/xattr_security.c   |   16 +++++++++-------
 6 files changed, 22 insertions(+), 33 deletions(-)

--
Signature
