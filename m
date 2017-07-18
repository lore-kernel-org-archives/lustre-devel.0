From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:46 +1000
Subject: [lustre-devel] [PATCH 00/12] Assorted lustre fixes and improvements
Message-ID: <150041997277.20736.17112251996623587423.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Hi,
 I've been looking through lustre, finding things, and fixing some of
 them.
 There are three distinct subsets of patches here.
 - 1 patch to fix a few typos in comments
 - 2 patches to fix dcache issues, particularly around
    DCACHE_DISCONNECTED
 - 9 patches to clean up code in ldlm_flock().  These started
   as some simple list_entry tidy-ups, and just grew....

 The most interesting from a review perspective is
      staging: lustre: llite: fix various issues with ll_splice_alias.
 there are real locking issues in there, but its hard to be 100%
 sure I've fixed them all and not introduced new issues.
 It would be *really* nice if we could get rid of the concept of
 "invalid" dentries, but I don't yet understand it well enough to
 propose and alternative.

Thanks,
NeilBrown

---

NeilBrown (12):
      staging: lustre: fix minor typos in comments
      staging: lustre: llite: fix incorrect DCACHE_DISCONNECTED test
      staging: lustre: llite: fix various issues with ll_splice_alias.
      staging: lustre: ldlm: remove 'first_enq' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unused 'work_list' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unneeded 'err' arg to ldlm_process_flock_lock()
      staging: lustre: ldlm: remove 'flags' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unused 'overlaps' variable
      staging: lustre: ldlm: remove 'flags' arg from ldlm_flock_destroy()
      staging: lustre: ldlm: tidy list walking in ldlm_flock()
      staging: lustre: ldlm: remove unnecessary 'ownlocks' variable.
      staging: lustre: ldlm: remove unused field 'fwd_generation'


 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  208 ++++----------------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/namei.c        |   71 +++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    4 
 4 files changed, 80 insertions(+), 205 deletions(-)

--
Signature
