From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Thu, 27 Jul 2017 10:26:58 +0200
Subject: [lustre-devel] Design proposal for client-side compression
In-Reply-To: <80491E10-0C6C-4826-AD55-5B78A20166D8@intel.com>
References: <1483967258.2622.24.camel@informatik.uni-hamburg.de>
	<B5E18A82-79B3-484F-BEBE-998B8AE56397@intel.com>
	<1484223328.3937.60.camel@informatik.uni-hamburg.de>
	<B924BE6D-3C6A-4BA4-96F9-AC053F032B2D@intel.com>
	<1484749185.3965.114.camel@informatik.uni-hamburg.de>
	<1487254536.4777.51.camel@informatik.uni-hamburg.de>
	<1500650130.3158.6.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132311AB19B104AD044797ACBA40@BN6PR1101MB2132.namprd11.prod.outlook.com>
	<1500992740.4728.5.camel@informatik.uni-hamburg.de>
	<BN6PR1101MB2132DD0CCFF2F83BB3BE7F54CBB90@BN6PR1101MB2132.namprd11.prod.outlook.com>
	<80491E10-0C6C-4826-AD55-5B78A20166D8@intel.com>
Message-ID: <1501144018.3412.4.camel@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Jinshan,

On Wed, 2017-07-26 at 20:17 +0000, Xiong, Jinshan wrote:
> Thanks for the detailed explanation from Patrick.
>  
> ?Does that mean, ? Is there not any limit how many one
> client can have at one point of time??
>  
> In theory, it?s possible that there exist that many active RPCs at
> one time, which is why I think it?s not feasible to have per-OSC page
> pool.

I see and agree, that could become a problem.

>  
> ?? Once we have a smaller pool than
> we need, we have to block or skip compression, which is undesirable.
> But I don't know how to determine the required size.?
>  
> It?s probably not good to skip compression once it runs out of pages
> in pool, instead it should be blocked waiting for pages to be
> available. It will spend some time on waiting for the available
> pages, but at the end it will transfer less data over the network,
> and OST will also write less data to disk, so that it can still be
> performant.
> Of course, we can make it smarter by checking if there are too many
> threads waiting for available pages, and in that case we decide to
> not compress some RPCs. But this work can be deferred to the time
> after we have the code running and tune it by actual workload.

You are totally right, the smart tuning will be the second part of our
work, when the infrastructure is done. To start with something, we can
currently just block. 

> In order to decide the size of the pool, we should consider the
> number of CPUs on the client node, and the default RPC size. Let?s
> start with MAX(32, number_of_cpus) * default_RPC_size, and the
> default RPC size is 4MB in 2.10+ releases.

Thank you very much for the suggestions and explanations!

Anna
