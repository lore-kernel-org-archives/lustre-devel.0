From: James Simmons <jsimmons@infradead.org>
Date: Fri, 28 Sep 2018 17:25:05 +0100 (BST)
Subject: [lustre-devel] [PATCH 33/34] lnet: use BIT() macro for
 LNET_MD_* flags
In-Reply-To: <153783763611.32103.14845537928418369718.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763611.32103.14845537928418369718.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809281724200.19403@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> As these are bit flags, it aids clarity to use the BIT()
> macro.

Nak. BIT is not for UAPI headers. Including this will break building
userland applications.
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> index e80ef4182e5d..62f062c0d1bf 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> @@ -483,22 +483,22 @@ struct lnet_md {
>  /**
>   * Options for the MD structure. See lnet_md::options.
>   */
> -#define LNET_MD_OP_PUT		(1 << 0)
> +#define LNET_MD_OP_PUT		BIT(0)
>  /** See lnet_md::options. */
> -#define LNET_MD_OP_GET		(1 << 1)
> +#define LNET_MD_OP_GET		BIT(1)
>  /** See lnet_md::options. */
> -#define LNET_MD_MANAGE_REMOTE	(1 << 2)
> -/* unused			(1 << 3) */
> +#define LNET_MD_MANAGE_REMOTE	BIT(2)
> +/* unused			BIT(3) */
>  /** See lnet_md::options. */
> -#define LNET_MD_TRUNCATE	(1 << 4)
> +#define LNET_MD_TRUNCATE	BIT(4)
>  /** See lnet_md::options. */
> -#define LNET_MD_ACK_DISABLE	(1 << 5)
> +#define LNET_MD_ACK_DISABLE	BIT(5)
>  /** See lnet_md::options. */
> -#define LNET_MD_IOVEC		(1 << 6)
> +#define LNET_MD_IOVEC		BIT(6)
>  /** See lnet_md::options. */
> -#define LNET_MD_MAX_SIZE	(1 << 7)
> +#define LNET_MD_MAX_SIZE	BIT(7)
>  /** See lnet_md::options. */
> -#define LNET_MD_KIOV		(1 << 8)
> +#define LNET_MD_KIOV		BIT(8)
>  
>  /* For compatibility with Cray Portals */
>  #define LNET_MD_PHYS		0
> 
> 
> 
