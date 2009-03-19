From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Thu, 19 Mar 2009 13:16:09 -0700
Subject: [Lustre-devel] LustreFS performance (update)
In-Reply-To: <FBA6537A-EC86-450A-B44F-3CDBDAF8AADD@Sun.COM>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<FBA6537A-EC86-450A-B44F-3CDBDAF8AADD@Sun.COM>
Message-ID: <49C2A809.7030900@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Howdy Vitaly,
   I like this.  It is quite comprehensive and detailed.  I'd like to 
offer a few constructive criticisms in hope that you will better achieve 
your goals.  Mostly I'll stick them in-line where they seem relevant, 
but I'll start with:
1)  Your write up is quite dense and terse.  I could follow the overall 
structure, but found it pretty tough going to understand any specific 
detail.  It really helps to work with someone who will write up the same 
information, but in a form with whole sentences and a minimum of 
acronyms or special symbols.  Define the acronyms you do use in a clear 
way in one place that I can refer back to.


Vitaly Fertman wrote:
> ****************************************************
> 	LustreFS benchmarking methodology.
> ****************************************************
> 
> The document aims to describe the benchmarking methodology which helps
> to understand the LustreFS performance and reveal LustreFS bottlenecks  
> in
> different configurations on different hardware, to ensure the next  
> LustreFS
> release does not downgrade comparing with a previous one. In other  
> words:
> 	Goal1. Understand the HEAD performance.
> 	Goal2. Compare HEAD and b1_6 (b1_8) performance.
> 
> To achieve the Goal1, the methodology suggests to test different  
> layers of
> software in the bottom-top direction, i.e. the underlying back-end,  
> the target
> server sitting on this back-end, the network connected to this target  
> and how
> the target performs through this network, etc up to the whole cluster.

I like this approach.  My own efforts tend to be at-scale testing at the 
whole-cluster end of the range, often in the presence of other cluster 
activity.  It is good to have the details of the underlying components 
documented.

...
> Obviously, it is not possible to perform all the thousands of tests in  
> all the configurations,
> running all the special purpose tests, etc, the document tries to  
> prepare:
> 1) all the essential and sufficient tests to see how the system  
> performs in general;
> 2) some minimal amount of essential tests to see how the system scales  
> in different
> conditions.

In some cases it's obvious, but in many it is not clear what exactly you 
mean to be testing.  It is a good extension to your methodology to state 
clearly not only the mechanics of the test itself, but what you think 
you are testing with the given experiment.  Spend a little time and 
describe what the system is under examination, how it responds or should 
respond to the proposed test, and what tunables and parameters you think 
might be relevant.  For instance, if the test is supposed to saturate 
the target server, then how much I/O do you expect will be required and 
why?  What timeout or other tunable may determine the observed 
saturation point.  Your goal should be to have, not only a test, but a 
real expectation about its results even before you run the test.  Once 
you have that expectation then you can evaluate the results.  The bottom 
up approach helps with this, since you can use the performance of the 
individual pieces to help establish your expectation about the larger 
assemblies.

...
> **** Hardware Requirements. ****
> 
> The test plan implies that we change only 1 parameter (cpu or disk or  
> network)
> on each step. The HW requirements are:
> 
> -- at least 1 node with:
>   CPU:32;
>   RAM: enough to have a ramdisk for MDS;
>   DISK: enough disks for raid6 or raid1+0 (as this node could be mds  
> or ost);
> 	  an extra disk for external journal;
>   NET: both GiGe and IB installed.
> -- at least 1 another node includes:
>   DISK: enough disks for raid6 or raid1+0 (as this node could be mds  
> or ost);
> 	  an extra disk for external journal;
> -- besides that: 8 clients, 3 other servers.
> -- the other servers include:
>   DISK: raid6
>   NET: IB installed.
> -- client includes:
> NET: both GiGe and IB installed.
> 
> **** Software requirements ****
> 
You might provide links to these tests for those not familiar with them.
> 1. Short term.
> 1.1 mdsrate
> to be completed to test all the operations listed in MDST3 (see below).
> 1.2 mdsrate-**.sh
> to be fixed/written to run mdsrate properly and test all the  
> operations listed in
> MDST3 (see below).
> 1.3. fake disk
> implement FAIL flag and report 'done' without doing anything in  
> obdfilter to get
> a low-latency disk.
> 1.4. MT.
> add more tests here and implement them.
> 
> 2. Long term.
> 2.1. mdtstack-survey
> - an echo client-server is to be written for mds similar to ost.
> - a test script similar to obdfilter-survey.sh is to be written.
> 
> **** Different configurations ****
> 
...

I'll cut it short here, but in general, I think you might be surprised 
that if you organize this document so that anyone else could come along 
behind you and perform all the same tests in the same way, you might get 
a lot of others doing these experiments along side you.  That would make 
your job a lot easier and increase the likelihood that bugs and 
regressions would be caught quickly.

> --
> Vitaly
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

Cheers,
Andrew
