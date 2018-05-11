From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:37:14 +1000
Subject: [lustre-devel] RFC: [PATCH 0/6] lustre: Improve locking in
 lu_object.s
Message-ID: <152599874625.19824.11344372150811845854.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This is a followup to the patches that James recently posted
which addressed some locking issues in lu_object.c.
I said at the time that I thought the locking could be
improved further.  Here is the result of that thought.

The lu_keys_guard lock is now gone, replaced by a spin lock, an rwsem,
and some lockless code.
The lu_context_exit() function, which appears to have been a
performance problem at one point, is now completely lockless.

This is an RFC at this stage: I haven't included Greg on the email and
don't expect this to go upstream without some review - and maybe even
some testing.

Thanks,
NeilBrown


---

NeilBrown (6):
      staging: lustre: make key_set_version an atomic_t
      staging: lustre: use an rwsem instead of lu_key_initing_cnt.
      staging: lustre: remove locking from lu_context_exit()
      staging: lustre: use wait_event_var() in lu_context_key_degister()
      staging: lustre: remove lock from key register/degister
      staging: lustre: rename lu_keys_guard to lu_context_remembered_guard


 drivers/staging/lustre/lustre/include/lu_object.h  |    1 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  187 ++++++++------------
 2 files changed, 78 insertions(+), 110 deletions(-)

--
Signature
