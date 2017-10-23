From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Oct 2017 11:53:49 +1100
Subject: [lustre-devel] [PATCH 0/9] Assorted cleanups for
 staging/.../lustre/ldlm/ldlm_flock.c
Message-ID: <150871988297.3340.4522589460981284121.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

This file contains quite a bit of dead code and unused variables.
This patch series cleans it up in various ways.
It should change behaviour at all, just code
readability/maintainabilty.

I sent the back in July but got not response, possibly because there
were included with other patches which caused a distraction.
So here they are by themselves.

Thanks,
NeilBrown


---

NeilBrown (9):
      staging: lustre: ldlm: remove 'first_enq' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unused 'work_list' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unneeded 'err' arg to ldlm_process_flock_lock()
      staging: lustre: ldlm: remove 'flags' arg from ldlm_process_flock_lock()
      staging: lustre: ldlm: remove unused 'overlaps' variable
      staging: lustre: ldlm: remove 'flags' arg from ldlm_flock_destroy()
      staging: lustre: ldlm: tidy list walking in ldlm_flock()
      staging: lustre: ldlm: remove unnecessary 'ownlocks' variable.
      staging: lustre: ldlm: remove unused field 'fwd_generation'


 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |  208 +++++------------------
 1 file changed, 42 insertions(+), 166 deletions(-)

--
Signature
