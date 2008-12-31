From: Eric Barton <eeb@sun.com>
Date: Wed, 31 Dec 2008 15:20:45 +0000
Subject: [Lustre-devel] global epochs v. dependencies
Message-ID: <01d001c96b5b$5a595650$0f0c02f0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

FYI...

<eeb>    any further thoughts on the subject of epochs?
<snip>
<bzzz_z> i'd appreciate very much if you could describe your concerns about
         overhead of dependency-based recovery
<eeb>    yes indeed
<bzzz_z> preferable in email so that i can look and think again and again 
<eeb>    sure - it's all about how communications combine 
<eeb>    I don't like nikita's idea either (reduction of a vector O(#clients)
	  in size)
<bzzz_z> my understanding is that nikita's idea is very simple to understand 
         and implement
<eeb>    yes - I agree with almost all of it apart from having to propagate 
         per-client info
<eeb>    but as we discussed - that is only required if clients don't
         participate in a fixed-topology reduction
<eeb>    when they do, the info to reduce is O(constant) 
<eeb>    which means you can afford to reduce it much more frequently 
<eeb>    if the reduction tree
<eeb>    hasn't got too high a branching ratio
<bzzz_z> i still think that having a single coordinator is bad thing and fsync 
         is a problem as well
<eeb>    no single coordinator required 
<bzzz_z> ? 
<eeb>    unless you want to call the root of the reduction tree "the 
         coordinator" - but really, it's just the server that knows the global
         reduction result first and broadcasts it back to the rest of the
         cluster via the other servers
<eeb>    in the tree 
<bzzz_z> well, this is a coordinator - single node deciding what epochs are 
         stable by given moment
<eeb>    no - it doesn't decide it 
<eeb>    the reduction is done in the tree 
<eeb>    the root of the tree is only combining information from its children 
         like any other non-leaf in the tree
<bzzz_z> one part of tree knows nothing abou different part of tree 
<bzzz_z> yes, but you can't make epoch N stable until you know another subtree
         has no N-10 finished
<eeb>    indeed 
<eeb>    every client tells its favourite server (and only its favourite
         server) its oldest volatile epoch
<eeb>    each server sends its parent the oldest volatile epoch computed over 
         itself and its clients
<eeb>    and tells its parent 
<eeb>    the parent computs the oldest volatile epoch over its children and
         tells its parent
<eeb>    etc 
<eeb>    until the root knows the global oldest volatile epoch 
<eeb>    the root tells its children the oldest global volatile epoch 
<eeb>    the children tell their children 
<bzzz_z> current epoch can come from different server, not from favorite 
         server.
<eeb>    and so on 
<eeb>    I don't understand your last statement 
<bzzz_z> ok, describing .. 
<bzzz_z> say, there is mds1 and mds2 
<bzzz_z> client1 has mds1 as a favorite, so client2 does with mds2 
<bzzz_z> client1 has it volatile epoch 20 and reports this to mds1 
<eeb>    c1 has oldest volatile epoch 20 and reports to mds1 
<bzzz_z> at same time clent2 has its volatile epoch 10 and reports this to mds2 
<eeb>    c1 has _oldest_ volatile epoch 10 and reports to mds2 
<eeb>    mds2 reports 10 to mds1 
<eeb>    mds1 now knows the oldest volatile epoch is 10 
<bzzz_z> mds1 can't make 20 stable till 10 is stable as well 
<eeb>    it tells mds2 10 is the oldest volatile opoch 
<eeb>    md1 tells c1 and mds2 tells c2 
<eeb>    now everyone knows 10 is the oldest volatile epoch 
<eeb>    what's the issue 
<eeb>    ? 
<bzzz_z> the issue is that you need all servers be involved 
<eeb>    yes - they inevitable all are when you have a large enough cluster and 
         volume of distributed operations
<bzzz_z> that's exactly the point 
<eeb>    so you need the # of messages and # of bytes in these messages that
         any individual server sees to be limited
<eeb>    otherwise you can't scale 
<eeb>    if you cannot combine messages, then you are doing an exchange, not a 
         reduction
<eeb>    reduction is far more scalable than exchange 
<bzzz_z> no, you're telling about some cluster doing *single* job. i'm telling 
         about cluster doing many jobs. in the last case you want to localize
         operations to some servers
<eeb>    I'm neutral about whether the cluster is doing a single job or
         multiple unrelated jobs
<eeb>    both use cases must scale 
<bzzz_z> requiring all servers in non-stop exchange makes big cluster very 
         vulnerable to failures
<eeb>    how is that different for dependencies? 
<bzzz_z> and the bigger cluster, the frequent failures 
<bzzz_z> because with dependency all exchange can be limited to servers 
         involved in operations. if /home/eeb lives on (mds1; mds2) and
         /home/bzzz lives on (mds3; mds4) then failure of mds5 doesnt impact me
         or you
<bzzz_z> even w/o failures, requiring all servers to interact all the time is 
         not very good - servers can be distributed over the globe
<bzzz_z> especially given most of operations aren't really distributed at all 
<eeb>    disagree - we discussed yesterday that WAN clients would have to use 
         proxy servers
<bzzz_z> because if they re, then performance will be bad 
<bzzz_z> proxy changes nothing, imho 
<eeb>    think again - a proxy does the global epoch calculation on behalf of
         the WAN clients
<eeb>    you can expect every mds to be involved in a distributed operation
         with every other mds after enough operations have been performed
<bzzz_z> expect doesn't mean "a lot of distributed operations all the time" 
<snip>
<bzzz_z> proxy doesn global epoch calculation, but it link between proxy and 
         remote part of cluster is broken, you can't make any progress with
         undo cancel - because they share epoch namespace
<snip>
<eeb>    the proxy server is just a low-latency client 
<eeb>    which bounds who needs to be involved in the global last volatile
         epoch calculation
<bzzz_z> my feeling is that we have very different sense of "scale" here: your 
         one is something about zillions of distributed operations over whole
         cluster all the time, my one is rather a zillions of local domains
         where working set belongs to
<eeb>    if you make each MDS the proxy for the lustre clients (like we do now 
         with having the master MDS do the RPCs to the slave MDSes) then you've
         limited the global oldest volatile epoch calculation to just the
         servers 
<eeb>    yes 
<eeb>    I agree with your last comment 
<eeb>    If you can convince me that we can achieve good load balance with a 
         scheme that can exploit locality - i.e. so you have mathematical
         bounds on the volume of non-local operations as a proportion of the
         whole - then I will start to believe more in dependencies :)
<bzzz_z> dependency-based recovery would work with any non-heterogenous setups 
         like usual, not requiring any special proxy. and i think it'd scale
         very well with "working sets"
<eeb>    ok - I think we both have stuff to think about now 
<eeb>    ttyl...
