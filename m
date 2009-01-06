From: Andreas Dilger <adilger@sun.com>
Date: Tue, 06 Jan 2009 12:59:58 -0700
Subject: [Lustre-devel] global epochs v. dependencies
In-Reply-To: <01d001c96b5b$5a595650$0f0c02f0$@com>
References: <01d001c96b5b$5a595650$0f0c02f0$@com>
Message-ID: <20090106195958.GC13721@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 31, 2008  15:20 +0000, Eric Barton wrote:
> <eeb>    what's the issue 
> <eeb>    ? 
> <bzzz_z> the issue is that you need all servers be involved 
> <eeb>    yes - they inevitable all are when you have a large enough cluster
>          and volume of distributed operations
> <bzzz_z> that's exactly the point 
> <eeb>    so you need the # of messages and # of bytes in these messages that
>          any individual server sees to be limited
> <eeb>    otherwise you can't scale 
> <eeb>    if you cannot combine messages, then you are doing an exchange, not
>          a reduction
> <eeb>    reduction is far more scalable than exchange 
> <bzzz_z> no, you're telling about some cluster doing *single* job. i'm
>          telling  about cluster doing many jobs. in the last case you want
>          to localize operations to some servers
> <eeb>    I'm neutral about whether the cluster is doing a single job or
>          multiple unrelated jobs
> <eeb>    both use cases must scale 
> <bzzz_z> requiring all servers in non-stop exchange makes big cluster very 
>          vulnerable to failures
> <eeb>    how is that different for dependencies? 
> <bzzz_z> and the bigger cluster, the frequent failures 
> <bzzz_z> because with dependency all exchange can be limited to servers 
>          involved in operations. if /home/eeb lives on (mds1; mds2) and
>          /home/bzzz lives on (mds3; mds4) then failure of mds5 doesnt impact
>          me or you

I tend to agree with Alex here - even in a "local" cluster there may be
administrative or technical reasons to bound subsets of the namespace to
a subset of the MDTs (e.g. MDT pools) and having those be autonomous would
be highly desirable both from a fault tolerance point of view and a load
balancing POV.

> <bzzz_z> even w/o failures, requiring all servers to interact all the time is 
>          not very good - servers can be distributed over the globe
> <bzzz_z> especially given most of operations aren't really distributed at all 
> <eeb>    disagree - we discussed yesterday that WAN clients would have to use 
>          proxy servers
> <bzzz_z> because if they re, then performance will be bad 
> <bzzz_z> proxy changes nothing, imho 
> <eeb>    think again - a proxy does the global epoch calculation on behalf of
>          the WAN clients
> <eeb>    you can expect every mds to be involved in a distributed operation
>          with every other mds after enough operations have been performed
> <bzzz_z> expect doesn't mean "a lot of distributed operations all the time" 
> <snip>
> <bzzz_z> proxy doesn global epoch calculation, but it link between proxy and 
>          remote part of cluster is broken, you can't make any progress with
>          undo cancel - because they share epoch namespace
> <snip>
> <eeb>    the proxy server is just a low-latency client 
> <eeb>    which bounds who needs to be involved in the global last volatile
>          epoch calculation
> <bzzz_z> my feeling is that we have very different sense of "scale" here:
>          your one is something about zillions of distributed operations over
>          whole cluster all the time, my one is rather a zillions of local
>          domains where working set belongs to
> <eeb>    if you make each MDS the proxy for the lustre clients (like we do
>          now with having the master MDS do the RPCs to the slave MDSes) then
>          you've limited the global oldest volatile epoch calculation to just
>          the servers 

This is exactly the kind of implementation that I hope we will end
up with - we DON'T have to have every client involved in the epochs,
only the servers and clients that are doing WBC (e.g. login nodes, proxy
clients for a WAN, etc).  This set would be flexible hopefully, so that
nodes like login nodes could temporarily start doing WBC operations
under load, but flush their state and return to "dumb" clients when idle.

Ideally, with a single MDT and all dumb clients (i.e. today's Lustre) it
would collapse into a much more simple setup like we have today with just
a single transno controlled by the MDT.

> <eeb>    yes 
> <eeb>    I agree with your last comment 
> <eeb>    If you can convince me that we can achieve good load balance with a 
>          scheme that can exploit locality - i.e. so you have mathematical
>          bounds on the volume of non-local operations as a proportion of the
>          whole - then I will start to believe more in dependencies :)
> <bzzz_z> dependency-based recovery would work with any non-heterogenous
>          setups like usual, not requiring any special proxy. and i think
>          it'd scale very well with "working sets"
> <eeb>    ok - I think we both have stuff to think about now 
> <eeb>    ttyl...
> 
> 

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
