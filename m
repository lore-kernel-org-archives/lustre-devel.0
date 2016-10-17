From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 17 Oct 2016 21:38:38 +0200
Subject: [lustre-devel] [PATCH] staging: lov.ko: lov_object.c: fix
 sparse warning setting function to static
In-Reply-To: <1476732112-21234-1-git-send-email-ryan@ryanswan.com>
References: <1476732112-21234-1-git-send-email-ryan@ryanswan.com>
Message-ID: <20161017193838.GC27179@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Oct 17, 2016 at 03:21:52PM -0400, Ryan Swan wrote:
> Fixed: sparse WARNING: symbol 'lov_read_and_clear_async_rc' was not declared. Should it be static?

I don't believe you actually test-built this change :(

> 
> Signed-off-by: Ryan Swan <ryan@ryanswan.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_object.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index 82b99e0..c42eef6 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -1532,7 +1532,7 @@ struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
>  	return lsm;
>  }
>  
> -int lov_read_and_clear_async_rc(struct cl_object *clob)
> +static int lov_read_and_clear_async_rc(struct cl_object *clob)

You are turning a symbol that is explicitly exported into a static one?
How is the compiler supposed to figure out what to do when you do that?

Again, always test-build your patches so you don't get a grumpy
maintainer telling you to test-build your patches...

greg k-h
