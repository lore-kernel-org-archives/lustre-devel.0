From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 02:11:47 +0000 (GMT)
Subject: [lustre-devel] [PATCH 2/4] lustre: use GFP_NOFS when
 lli_och_mutex is held - again
In-Reply-To: <154440277646.29887.1527233404610585779.stgit@noble>
References: <154440246926.29887.1667505755325904791.stgit@noble>
 <154440277646.29887.1527233404610585779.stgit@noble>
Message-ID: <alpine.LFD.2.21.1812270210560.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> lockdep reports that lli_och_mutex is involved with fs_reclaim and is
> held during this memory allocation - so GFP_NOFS should be used to
> avoid a possible deadlock.
> 
> This is a second place where this was a problem - I don't think there
> are more.

Famous last words :-)

Signed-off-by: James Simmons <jsimmons@infradead.org>
 
> Fixes: 0b0c8c1ca0bd ("lustre: llite: replace several GFP_NOFS with GFP_KERNEL")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/llite/file.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index 15910ff5f293..a6f149c47a7a 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -135,7 +135,7 @@ static int ll_close_inode_openhandle(struct inode *inode,
>  		goto out;
>  	}
>  
> -	op_data = kzalloc(sizeof(*op_data), GFP_KERNEL);
> +	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
>  	/*
>  	 * We leak openhandle and request here on error, but not much to be
>  	 * done in OOM case since app won't retry close on error either.
> @@ -1652,7 +1652,7 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
>  
>  	LASSERT(it_open_error(DISP_OPEN_OPEN, it) == 0);
>  
> -	och = kzalloc(sizeof(*och), GFP_KERNEL);
> +	och = kzalloc(sizeof(*och), GFP_NOFS);
>  	if (!och) {
>  		rc = -ENOMEM;
>  		goto out;
> 
> 
> 
