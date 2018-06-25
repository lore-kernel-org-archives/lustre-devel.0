From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:33:53 +1000
Subject: [lustre-devel] [PATCH v3 00/26] staging: lustre: libcfs: SMP
 rework
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87lgb38xa6.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> Recently lustre support has been expanded to extreme machines with as
> many as a 1000+ cores. On the other end lustre also has been ported
> to platforms like ARM and KNL which have uniquie NUMA and core setup.
> For example some devices exist that have NUMA nodes with no cores.
> With these new platforms the limitations of the Lustre's SMP code
> came to light so a lot of work was needed. This resulted in this
> patch set which has been tested on these platforms.
>
> This is the 3rd version of this patch set with the first two submitted
> to the staging list. This latest patchset is identical to the 2nd one
> expect that the UMP support has been moved to the last patches in this
> collection. The approach to support UMP also has changed with using
> static initialization to greatly simplify the code.

Thanks for these.
Apart from some patches that I've rejected and some that I've modified,
these should appear in my lustre-testing branch in the next 24 hours.
I expect them to migrate to my lustre branch next Monday if no problems
surface.

Thanks,
NeilBrown


>
> Amir Shehata (8):
>   staging: lustre: libcfs: replace MAX_NUMNODES with nr_node_ids
>   staging: lustre: libcfs: remove excess space
>   staging: lustre: libcfs: replace num_possible_cpus() with nr_cpu_ids
>   staging: lustre: libcfs: NUMA support
>   staging: lustre: libcfs: add cpu distance handling
>   staging: lustre: libcfs: use distance in cpu and node handling
>   staging: lustre: libcfs: provide debugfs files for distance handling
>   staging: lustre: libcfs: invert error handling for cfs_cpt_table_print
>
> Dmitry Eremin (14):
>   staging: lustre: libcfs: remove useless CPU partition code
>   staging: lustre: libcfs: rename variable i to cpu
>   staging: lustre: libcfs: fix libcfs_cpu coding style
>   staging: lustre: libcfs: use int type for CPT identification.
>   staging: lustre: libcfs: rename i to node for cfs_cpt_set_nodemask
>   staging: lustre: libcfs: rename i to cpu for cfs_cpt_bind
>   staging: lustre: libcfs: rename cpumask_var_t variables to *_mask
>   staging: lustre: libcfs: update debug messages
>   staging: lustre: libcfs: make tolerant to offline CPUs and empty NUMA nodes
>   staging: lustre: libcfs: report NUMA node instead of just node
>   staging: lustre: libcfs: update debug messages in CPT code
>   staging: lustre: libcfs: rework CPU pattern parsing code
>   staging: lustre: libcfs: change CPT estimate algorithm
>   staging: lustre: ptlrpc: use current CPU instead of hardcoded 0
>
> James Simmons (4):
>   staging: lustre: libcfs: properly handle failure cases in SMP code
>   staging: lustre: libcfs: restore debugfs table reporting for UMP
>   staging: lustre: libcfs: make cfs_cpt_tab a static structure
>   staging: lustre: libcfs: restore UMP support
>
>  .../lustre/include/linux/libcfs/libcfs_cpu.h       |  203 ++--
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 1020 +++++++++++---------
>  drivers/staging/lustre/lnet/libcfs/module.c        |   52 +-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 +-
>  drivers/staging/lustre/lnet/lnet/lib-msg.c         |    2 +
>  drivers/staging/lustre/lnet/selftest/framework.c   |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |    4 +-
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   10 +-
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |   15 +-
>  9 files changed, 750 insertions(+), 562 deletions(-)
>
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/50229983/attachment-0001.sig>
