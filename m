From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:16:06 +0100 (BST)
Subject: [lustre-devel] [PATCH 0/6] lustre: convert list_for_each() to
 list_for_each_entry()
In-Reply-To: <153292233170.26104.16164388413209501300.stgit@noble>
References: <153292233170.26104.16164388413209501300.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020415100.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> list_for_each_entry(foo) is generally preferred to
>   list_for_each(l,...)
>      foo = list_entry(l,...)
> 
> as there is less noise in the code.
> The first patch contains seveveral trivial conversions.
> The remaining patches are less obvious and are separate
> so they are easier to review.
> 
> NeilBrown
> 
> The following series implements...

Looks good and testing shows no problems. I will poke the LNet
guys to look at these as well.
 
> ---
> 
> NeilBrown (6):
>       lustre: convert list_for_each() to list_for_each_entry().
>       lustre: lnet/config: convert list_for_each to list_for_each_entry
>       lustre: convert list_for_each in ksocknal_create_routes
>       lustre: convert list_for_each in ksocknal_close_conn_locked()
>       lustre: convert list_for_each() in ksocknal_push_peer()
>       lustre: convert list_for_each() in ksocknal_debug_peerhash()
> 
> 
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   17 --
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   20 +-
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  166 +++++++-------------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   20 +-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   29 +--
>  drivers/staging/lustre/lnet/lnet/config.c          |   28 +--
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    9 -
>  drivers/staging/lustre/lnet/lnet/router.c          |   47 +-----
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    7 -
>  drivers/staging/lustre/lustre/obdclass/genops.c    |    4 
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    4 
>  11 files changed, 99 insertions(+), 252 deletions(-)
> 
> --
> Signature
> 
> 
