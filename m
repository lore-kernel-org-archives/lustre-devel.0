From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jul 2018 09:04:51 +1000
Subject: [lustre-devel] [PATCH v4 00/14] lustre: libcfs: tracefile
 cleanups
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <871sbsp758.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Jul 07 2018, James Simmons wrote:

> The 4th version of a patch series aimed to cleanup the lustre tracefile
> handling. This set is mainly a repost of the 3rd set with the addition
> of a bug fix, patch number 2, that added proper range checking for the
> debugfs parameter debug_mb. The 6th patch has been updated based on
> Andreas Dilger's feedback to resolve the brokeness of cfs_print_to_console().
> This patch series has been reposted to allow anyone interested in testing
> the the major changes are in the 6th and 7th patch which was rebased due
> to changes in the code.
>
> James Simmons (6):
>   lustre: libcfs: properly handle failure paths in cfs_tracefile_init_arch()
>   lustre: libcfs: fix cfs_print_to_console()
>   lustre: libcfs: remove cfs_trace_refill_stack()
>   lustre: libcfs: move cfs_trace_data data to tracefile.c
>   lustre: libcfs: cleanup tracefile.h
>   lustre: libcfs: format macros in tracefile.h
>
> NeilBrown (8):
>   lustre: libcfs: move tracefile locking from linux-tracefile.c to tracefile.c
>   lustre: libcfs: always range-check libcfs_debug_mb setting.
>   lustre: libcfs: open code cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
>   lustre: libcfs: move tcd locking across to tracefile.c
>   lustre: libcfs: merge linux-tracefile.c into tracefile.c
>   lustre: libcfs: fold cfs_tracefile_*_arch into their only callers.
>   lustre: libcfs: renamed CFS_TCD_TYPE_MAX to CFS_TCD_TYPE_CNT
>   lustre: libcfs: discard TCD_MAX_TYPES

Thanks.
I've applied these now, included them in the 'lustre' branch, and pushed
it all out.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180725/d6bca0ff/attachment.sig>
