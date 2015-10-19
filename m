From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Mon, 19 Oct 2015 14:33:28 +0200
Subject: [lustre-devel] lustre: TODO updated?
In-Reply-To: <E50244C5-9F99-49A9-9FF6-96527BD0BE9C@intel.com>
References: <561CF52C.2070806@gmail.com>
	<E50244C5-9F99-49A9-9FF6-96527BD0BE9C@intel.com>
Message-ID: <5624E318.2000302@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/15/2015 08:55 PM, Drokin, Oleg wrote:

> Yes, it's still accurate from 10.000 ft view.
> 
> If you need some more detailed ideas, here's my current list of stuff:
> 
>  getting rid of remaining lustre allocation macros: OBD_SLAB_ALLOC/FREE and friends much like we got rid of
>  OBD_ALLOC/FREE before.
>  I think LIBCFS_ALLOC/FREE and friends would need the same treatment.
> 
>  I bet there are other wrapping functions (from libcfs compat code and such)
>  that need to be removed.
> 
>  typedefs: we did remove some, there are more left that need to be taken care of.
> 
>  Coding style - we are much better now here and the work is ongoing by a lot of
>  other people.
> 
>  Function defines - need to be looked into.
> 
>  In addition, more involved ones:
> 
>  After that there are more laborous ones like figuring out how to fit into the
>  perf framework as one example.
> 
>  Also we need to rip remaining parts of server code that is still present greatly there
>  (one example - oti handle users are either server only or client only with dummy
>   handle - in echo code only. These could be greatly pruned.
>   Then we can cleanup all the obd method tables to remove now unused pointers and so on).

Could you please reflect these things in TODO file ?

-thanks-
