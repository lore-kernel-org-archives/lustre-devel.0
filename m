From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 23 Jun 2015 11:35:42 +0200 (CEST)
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fid: Use !x to
 check for kzalloc failure
In-Reply-To: <20150623092303.GN28762@mwanda>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<20150623092303.GN28762@mwanda>
Message-ID: <alpine.DEB.2.10.1506231127120.2554@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 23 Jun 2015, Dan Carpenter wrote:

> On Tue, Jun 23, 2015 at 08:25:05AM +0000, Dilger, Andreas wrote:
> > I've found in the past that developers can introduce bugs when they treat
> > return values as boolean when they really aren't.
>
> I can imagine a bug like that where a function can return 0-2 and people
> do:
>
> 	if (ret)
>
> instead of:
>
> 	if (ret == 1)
>
> but that bug is something else besides pointers so it doesn't apply
> here.
>
> What someone should do is try to measure it scientifically where we
> flash some code on the screen and you have to press J for NULL and K for
> non-NULL and we time it to the hundredth of a second.  I have a feeling
> that (NULL != foo) is the worst way to write it because of the double
> negative Yoda code.
>
> Yoda code is the most useless thing ever.  I have actually measured this
> and we introduce about 2 = vs == bugs per year.  It's probably less now
> that we have so many static checks against it.  But people decided that
> Yoda code was a good idea based on their gut instead of using statistics
> and measurements and science.

In 2007, Al Viro said (https://lkml.org/lkml/2007/7/27/103):

Idiomatic form for "has allocation succeeded?" is neither "if (p != 0)"
nor "if (p != NULL)".  It's simply "if (p)".


From the point of view of looking at kernel code, x == NULL for the result
of kmalloc etc looks verbose and distracting.

julia
