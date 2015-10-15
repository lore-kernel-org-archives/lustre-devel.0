From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Thu, 15 Oct 2015 18:55:57 +0000
Subject: [lustre-devel] lustre: TODO updated?
In-Reply-To: <561CF52C.2070806@gmail.com>
References: <561CF52C.2070806@gmail.com>
Message-ID: <E50244C5-9F99-49A9-9FF6-96527BD0BE9C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Oct 13, 2015, at 8:12 AM, Xose Vazquez Perez wrote:

> Is drivers/staging/lustre/TODO file updated?

Yes, it's still accurate from 10.000 ft view.

If you need some more detailed ideas, here's my current list of stuff:

 getting rid of remaining lustre allocation macros: OBD_SLAB_ALLOC/FREE and friends much like we got rid of
 OBD_ALLOC/FREE before.
 I think LIBCFS_ALLOC/FREE and friends would need the same treatment.

 I bet there are other wrapping functions (from libcfs compat code and such)
 that need to be removed.

 typedefs: we did remove some, there are more left that need to be taken care of.

 Coding style - we are much better now here and the work is ongoing by a lot of
 other people.

 Function defines - need to be looked into.

 In addition, more involved ones:

 After that there are more laborous ones like figuring out how to fit into the
 perf framework as one example.

 Also we need to rip remaining parts of server code that is still present greatly there
 (one example - oti handle users are either server only or client only with dummy
  handle - in echo code only. These could be greatly pruned.
  Then we can cleanup all the obd method tables to remove now unused pointers and so on).

Bye,
    Oleg
