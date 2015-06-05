From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 5 Jun 2015 12:02:27 +0300
Subject: [lustre-devel] [PATCH v3 5/8] staging:lustre: separate kernel
 and user land defines in the LNet headers
In-Reply-To: <1433364207-14307-6-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
	<1433364207-14307-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20150605090226.GM28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 04:43:24PM -0400, James Simmons wrote:
> Currently the lnet headers used by user land contain various internal
> LNet structures that are only used by kernel space. Move the user land
> structures to headers used by user land. The kernel structures are
> relocated to headers that are never exposed to user land.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> index 1dc7c8a..4928f5c 100644
> --- a/drivers/staging/lustre/lnet/lnet/acceptor.c
> +++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
> @@ -243,8 +243,6 @@ lnet_accept(struct socket *sock, __u32 magic)
>  
>  		if (magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC))
>  			str = "'old' socknal/tcpnal";
> -		else if (lnet_accept_magic(magic, LNET_PROTO_RA_MAGIC))
> -			str = "'old' ranal";
>  		else
>  			str = "unrecognised";
>  

Presumably this was done intentionally.  We deleted LNET_PROTO_RA_MAGIC.
The changelog was not very clear why.

regards,
dan carpenter
