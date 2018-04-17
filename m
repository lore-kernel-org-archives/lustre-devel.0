From: James Simmons <jsimmons@infradead.org>
Date: Tue, 17 Apr 2018 04:35:43 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/20] staging: lustre: convert to
 rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <alpine.LFD.2.21.1804170429300.14398@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> libcfs in lustre has a resizeable hashtable.
> Linux already has a resizeable hashtable, rhashtable, which is better
> is most metrics. See https://lwn.net/Articles/751374/ in a few days
> for an introduction to rhashtable.

Thansk for starting this work. I was think about cleaning the libcfs
hash but your port to rhashtables is way better. How did you gather
metrics to see that rhashtable was better than libcfs hash?
 
> This series converts lustre to use rhashtable.  This affects several
> different tables, and each is different is various ways.
> 
> There are two outstanding issues.  One is that a bug in rhashtable
> means that we cannot enable auto-shrinking in one of the tables.  That
> is documented as appropriate and should be fixed soon.
> 
> The other is that rhashtable has an atomic_t which counts the elements
> in a hash table.  At least one table in lustre went to some trouble to
> avoid any table-wide atomics, so that could lead to a regression.
> I'm hoping that rhashtable can be enhanced with the option of a
> per-cpu counter, or similar.
> 

This doesn't sound quite ready to land just yet. This will have to do some
soak testing and a larger scope of test to make sure no new regressions
happen. Believe me I did work to make lustre work better on tickless 
systems, which I'm preparing for the linux client, and small changes could 
break things in interesting ways. I will port the rhashtable change to the 
Intel developement branch and get people more familar with the hash code
to look at it. 

> I have enabled automatic shrinking on all tables where it makes sense
> and doesn't trigger the bug.  I have also removed all hints concerning
> min/max size - I cannot see how these could be useful.
> 
> The dump_pgcache debugfs file provided some interesting challenges.  I
> think I have cleaned it up enough so that it all makes sense.  An
> extra pair of eyes examining that code in particular would be
> appreciated.
> 
> This series passes all the same tests that pass before the patches are
> applied.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (20):
>       staging: lustre: ptlrpc: convert conn_hash to rhashtable
>       staging: lustre: convert lov_pool to use rhashtable
>       staging: lustre: convert obd uuid hash to rhashtable
>       staging: lustre: convert osc_quota hash to rhashtable
>       staging: lustre: separate buckets from ldlm hash table
>       staging: lustre: ldlm: add a counter to the per-namespace data
>       staging: lustre: ldlm: store name directly in namespace.
>       staging: lustre: simplify ldlm_ns_hash_defs[]
>       staging: lustre: convert ldlm_resource hash to rhashtable.
>       staging: lustre: make struct lu_site_bkt_data private
>       staging: lustre: lu_object: discard extra lru count.
>       staging: lustre: lu_object: factor out extra per-bucket data
>       staging: lustre: lu_object: move retry logic inside htable_lookup
>       staging: lustre: fold lu_object_new() into lu_object_find_at()
>       staging: lustre: llite: use more private data in dump_pgcache
>       staging: lustre: llite: remove redundant lookup in dump_pgcache
>       staging: lustre: use call_rcu() to free lu_object_headers
>       staging: lustre: change how "dump_page_cache" walks a hash table
>       staging: lustre: convert lu_object cache to rhashtable
>       staging: lustre: remove cfs_hash resizeable hashtable implementation.
> 
> 
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
>  .../lustre/include/linux/libcfs/libcfs_hash.h      |  866 --------
>  drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
>  drivers/staging/lustre/lnet/libcfs/hash.c          | 2064 --------------------
>  drivers/staging/lustre/lnet/libcfs/module.c        |   12 
>  drivers/staging/lustre/lustre/include/lu_object.h  |   55 -
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |   19 
>  .../staging/lustre/lustre/include/lustre_export.h  |    2 
>  drivers/staging/lustre/lustre/include/lustre_net.h |    4 
>  drivers/staging/lustre/lustre/include/obd.h        |   11 
>  .../staging/lustre/lustre/include/obd_support.h    |    9 
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   31 
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  370 +---
>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    8 
>  drivers/staging/lustre/lustre/llite/vvp_dev.c      |  332 +--
>  drivers/staging/lustre/lustre/llite/vvp_object.c   |    9 
>  drivers/staging/lustre/lustre/lov/lov_internal.h   |   11 
>  drivers/staging/lustre/lustre/lov/lov_obd.c        |   12 
>  drivers/staging/lustre/lustre/lov/lov_object.c     |    8 
>  drivers/staging/lustre/lustre/lov/lov_pool.c       |  159 +-
>  drivers/staging/lustre/lustre/lov/lovsub_object.c  |    9 
>  drivers/staging/lustre/lustre/obdclass/genops.c    |   34 
>  drivers/staging/lustre/lustre/obdclass/lu_object.c |  564 ++---
>  .../staging/lustre/lustre/obdclass/obd_config.c    |  161 +-
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    8 
>  drivers/staging/lustre/lustre/osc/osc_internal.h   |    5 
>  drivers/staging/lustre/lustre/osc/osc_quota.c      |  136 -
>  drivers/staging/lustre/lustre/osc/osc_request.c    |   12 
>  drivers/staging/lustre/lustre/ptlrpc/connection.c  |  164 +-
>  29 files changed, 870 insertions(+), 4208 deletions(-)
>  delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
>  delete mode 100644 drivers/staging/lustre/lnet/libcfs/hash.c
> 
> --
> Signature
> 
> 
