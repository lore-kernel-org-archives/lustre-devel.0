From: Julia Lawall <julia.lawall@lip6.fr>
Date: Wed, 10 Jun 2015 19:16:51 +0200 (CEST)
Subject: [lustre-devel] Working on client merge
In-Reply-To: <3c566cdc50934ed6a1c5a629172da29c@EXCHCS32.ornl.gov>
References: <6E6D936CCB2E3C428716BD24C5C6CDF2643227@CFWEX01.americas.cray.com>
	<3c566cdc50934ed6a1c5a629172da29c@EXCHCS32.ornl.gov>
Message-ID: <alpine.DEB.2.10.1506101915280.5463@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Wed, 10 Jun 2015, Simmons, James A. wrote:

>
> >Where would be a good place to get started with helping merge the client
> into mainline?
>
> ?
>
> Hi Ben
>
> ?
>
> ???? Thanks for helping out for this work. I added people in the chain that
> have contributed a great
>
> deal to the upstream client so we can coordinate our work. Also I like to
> make people aware
>
> a lustre IRC channel does exist. ??Andreas can supply the details about the
> IRC channel. Currently
>
> my work has been focused on the libcfs/lnet layer. I had discuss early with
> Mike Shuey ?since he
>
> was also working in that area but will be migrating to the lustre core.
>
> ?
>
> ??? Since more people are getting involved we need to find? a way to break
> up the work to avoid
>
> duplicate work. Should the work be broken ?up by layer, i.e lov, mdc, or by
> task such as removing
>
> specific checkpatch errors with files?

For the work I have done with Coccinelle, it is more convenient to do the
whole thing.  Breaking things up by layer is not helpful.

This is just a data point, though. It doesn't have to imply anything about
how others work on the code.

julia
