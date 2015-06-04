From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Thu, 4 Jun 2015 11:32:47 +0530
Subject: [lustre-devel] [PATCH v4 6/7] staging:lustre: style cleanups
	for lib-socket.c
In-Reply-To: <1433361433-24976-7-git-send-email-jsimmons@infradead.org>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-7-git-send-email-jsimmons@infradead.org>
Message-ID: <20150604060247.GD6376@sudip-PC>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 03:57:12PM -0400, James Simmons wrote:
> Handle all the style issues reported by checkpatch.pl.
> Remove general white spaces, spaces in function calls,
> etc.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
<snip>
> @@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
>  		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
>  			toobig = 1;
>  			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
> -			CWARN("Too many interfaces: only enumerating first %d\n",
> -			      nalloc);
> +			CWARN("Too many interfaces: only enumerating "
> +			      "first %d\n", nalloc);
oops. Joe told you not to break the user visible strings.

The CodingStyle says: "However, never break user-visible strings such as
printk messages, because that breaks the ability to grep for them."

regards
sudip
