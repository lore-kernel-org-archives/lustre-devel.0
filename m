From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 25 May 2015 12:37:38 +0300
Subject: [lustre-devel] [PATCH 5/6] staging:lustre: style cleanups for
	lib-socket.c
In-Reply-To: <1432319552-10479-6-git-send-email-jsimmons@infradead.org>
References: <uja.ornl@gmail.com>
	<1432319552-10479-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20150525093737.GS4150@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, May 22, 2015 at 02:32:31PM -0400, James Simmons wrote:
> @@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
>  		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
>  			toobig = 1;
>  			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
> -			CWARN("Too many interfaces: only enumerating first %d\n",
> -			      nalloc);
> +			CWARN("Too many interfaces: only enumerating "
> +			      "first %d\n", nalloc);
>  		}

Don't split string literals, it makes them hard to grep for.

regards,
dan carpenter
