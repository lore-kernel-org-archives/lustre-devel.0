From: Julia Lawall <julia.lawall@lip6.fr>
Date: Sun, 4 Mar 2018 16:55:39 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 0/3] staging: lustre:
 cleanup
In-Reply-To: <1520172968-17448-1-git-send-email-arushisinghal19971997@gmail.com>
References: <1520172968-17448-1-git-send-email-arushisinghal19971997@gmail.com>
Message-ID: <alpine.DEB.2.20.1803041655150.2182@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, outreachy-kernel@googlegroups.com



On Sun, 4 Mar 2018, Arushi Singhal wrote:

> Spellcheck the comments.
> Remove the repeated, consecutive words with single word.
>
> Arushi Singhal (3):
>   staging: lustre: Replace "be be" with "be"
>   staging: lustre: Replace "to to" with "to"
>   staging: lustre: Replace "dont" with "don't"

For the series:
Acked-by: Julia Lawall <julia.lawall@lip6.fr>

>
>  drivers/staging/lustre/lnet/libcfs/debug.c             | 2 +-
>  drivers/staging/lustre/lustre/fld/fld_cache.c          | 2 +-
>  drivers/staging/lustre/lustre/include/cl_object.h      | 2 +-
>  drivers/staging/lustre/lustre/include/lprocfs_status.h | 2 +-
>  4 files changed, 4 insertions(+), 4 deletions(-)
>
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> To post to this group, send email to outreachy-kernel at googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1520172968-17448-1-git-send-email-arushisinghal19971997%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.
>
