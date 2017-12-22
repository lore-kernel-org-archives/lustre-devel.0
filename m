From: NeilBrown <neilb@suse.com>
Date: Fri, 22 Dec 2017 14:11:03 +1100
Subject: [lustre-devel] [PATCH 0/2] Add new wait_event macros to support
 lustre
Message-ID: <151391203805.23157.8332034037737592042.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, lustre <lustre-devel@lists.lustre.org>

Lustre has its own l_wait_event() macro to support waiting.
Some uses can be converted to current wait_event macros, but others
cannot.

Particularly it needs to be able to wait in TASK_IDLE state, and needs
exclusive waiters to be placed at the head of the queue.
These two patches add required functionalty to wait.h so that
lustre can be fully moved away from l_wait_event()

Thanks,
NeilBrown

---

NeilBrown (2):
      sched/wait: add wait_event_idle() functions.
      sched/wait: add wait_event_idle_exclusive_lifo()


 include/linux/wait.h |  170 +++++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/wait.c  |    3 +
 2 files changed, 167 insertions(+), 6 deletions(-)

--
Signature
