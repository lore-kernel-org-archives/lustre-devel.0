From: Joe Perches <joe@perches.com>
Date: Wed, 03 Jun 2015 10:16:44 -0700
Subject: [lustre-devel] [PATCH v3 6/7] staging:lustre: style cleanups
 for lib-socket.c
In-Reply-To: <b8dcda1e71e843699993f689521336bf@EXCHCS32.ornl.gov>
References: <1433341954-654-1-git-send-email-jsimmons@infradead.org>
	<1433341954-654-7-git-send-email-jsimmons@infradead.org>
	<1433342574.4861.126.camel@perches.com>
	<b8dcda1e71e843699993f689521336bf@EXCHCS32.ornl.gov>
Message-ID: <1433351804.4861.134.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2015-06-03 at 17:12 +0000, Simmons, James A. wrote:
> >On Wed, 2015-06-03 at 10:32 -0400, James Simmons wrote:
> >> Handle all the style issues reported by checkpatch.pl.
> >> Remove general white spaces, spaces in function calls,
> >> etc.
> >[]
> >> @@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
> >>  		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
> >>  			toobig = 1;
> >>  			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
> >> -			CWARN("Too many interfaces: only enumerating first %d\n",
> >> -			      nalloc);
> >> +			CWARN("Too many interfaces: only enumerating "
> >> +			      "first %d\n", nalloc);
> >
> >Please don't split single strings into multiple parts.
> >
> >For a patch like this it'd be nice to specify that both
> >"git diff -w" and scripts/objdiff shows no differences.
> >
> >Unless it does...
> 
> Two patches have mistakes. Should I send a new series or do a in-reply instead.

Most of the time, it's better to send a new series.

If any of the unmodified patches are very large, like 100KB+,
then it can be better to send individually updated patches.
