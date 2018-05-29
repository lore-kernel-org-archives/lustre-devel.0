From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:40 -0400
Subject: [lustre-devel] [PATCH v2 00/25] staging: lustre: libcfs: SMP rework
Message-ID: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>

From: James Simmons <uja.ornl@yahoo.com>

Recently lustre support has been expanded to extreme machines with as
many as a 1000+ cores. On the other end lustre also has been ported
to platforms like ARM and KNL which have uniquie NUMA and core setup.
For example some devices exist that have NUMA nodes with no cores.
With these new platforms the limitations of the Lustre's SMP code
came to light so a lot of work was needed. This resulted in this
patch set which has been tested on these platforms.

Amir Shehata (8):
  staging: lustre: libcfs: replace MAX_NUMNODES with nr_node_ids
  staging: lustre: libcfs: remove excess space
  staging: lustre: libcfs: replace num_possible_cpus() with nr_cpu_ids
  staging: lustre: libcfs: NUMA support
  staging: lustre: libcfs: add cpu distance handling
  staging: lustre: libcfs: use distance in cpu and node handling
  staging: lustre: libcfs: provide debugfs files for distance handling
  staging: lustre: libcfs: invert error handling for cfs_cpt_table_print

Dmitry Eremin (15):
  staging: lustre: libcfs: remove useless CPU partition code
  staging: lustre: libcfs: rename variable i to cpu
  staging: lustre: libcfs: fix libcfs_cpu coding style
  staging: lustre: libcfs: use int type for CPT identification.
  staging: lustre: libcfs: rename i to node for cfs_cpt_set_nodemask
  staging: lustre: libcfs: rename i to cpu for cfs_cpt_bind
  staging: lustre: libcfs: rename cpumask_var_t variables to *_mask
  staging: lustre: libcfs: rename goto label in cfs_cpt_table_print
  staging: lustre: libcfs: update debug messages
  staging: lustre: libcfs: make tolerant to offline CPUs and empty NUMA nodes
  staging: lustre: libcfs: report NUMA node instead of just node
  staging: lustre: libcfs: update debug messages in CPT code
  staging: lustre: libcfs: rework CPU pattern parsing code
  staging: lustre: libcfs: change CPT estimate algorithm
  staging: lustre: ptlrpc: use current CPU instead of hardcoded 0

James Simmons (2):
  staging: lustre: libcfs: restore UMP handling
  staging: lustre: libcfs: properly handle failure cases in SMP code

 .../lustre/include/linux/libcfs/libcfs_cpu.h       | 225 +++--
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 965 +++++++++++----------
 drivers/staging/lustre/lnet/libcfs/module.c        |  57 ++
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   2 +
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  11 +-
 5 files changed, 728 insertions(+), 532 deletions(-)

-- 
1.8.3.1
