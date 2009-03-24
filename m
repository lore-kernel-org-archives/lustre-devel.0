From: Eric Barton <eeb@sun.com>
Date: Mon, 23 Mar 2009 17:34:17 -0700
Subject: [Lustre-devel] LustreFS performance (update)
In-Reply-To: <49C32DDE.1030705@sun.com>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<FBA6537A-EC86-450A-B44F-3CDBDAF8AADD@Sun.COM>
	<49C32DDE.1030705@sun.com>
Message-ID: <005e01c9ac18$4f0107f0$ed0317d0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vitaly,

I've been following this thread with great interest and I'd like
to chat with you about this and also the MDS performance regression
tests.  Unfortunately, I'm unlikely to be able to do that this week
and it will probably have to wait until I'm back in the UK next
week.  In the mean time...

1. Have you got a rough idea how much work it would be to write the
   software that could exercise the MDD directly?  I'd just like to
   know if we're talking days or weeks or months - we need to know
   that before we decide whether to do it.

2. I think Andrew Uselton's comments are helpful.  We cannot afford
   routinely to sample the whole performance space - there are just
   too many dimensions.  So we need to develop a performance model
   that allows us to restrict the number of measurements we need
   to be confident that there are no surprises "in between" the
   points we have sampled.   

   That means we have to start running tests as soon as possible over
   as wide a parameter range as possible, with as much hardware as
   possible.  Then we'll start to get a feel how much variability
   there is all over the space and where the "edges" and asymptotes
   are.

3. It's worthwhile taking time to analyse and present results with care.
   I've attached a spreadsheet that compares ping performance of a single
   8-core server with varying numbers of clients and client threads,
   measured using different LNET locking schemes - hp (HEAD ping), 2lp
   (HEAD modified to split the LNET global lock into 2) and 3lp (same, but
   splitting the LNET global lock into 3).

   The lower row of graphs shows ping throughput versus number of client
   nodes, with different numbers of threads per node in each series.  The
   upper row of graphs shows the same ping throughput, but plotted
   against client threads totalled over all nodes, with different numbers
   of nodes in each series.  Please note....

   a) Set axis scaling correctly so that visual comparison is accurate.

   b) The upper row of graphs shows that it's the total number of threads
      exercising the server that's most important - and that how those
      threads are distributed over client nodes seems to matter most when
      there are 8 of them.  That's absolutely _not_ obvious from looking
      at the lower row of graphs.

    Cheers,
              Eric

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of parinay
> kondekar
> Sent: 19 March 2009 10:47 PM
> To: Vitaly Fertman
> Cc: lustre-2.0-performance at sun.com; minh diep; Lustre Development Mailing List
> Subject: Re: [Lustre-devel] LustreFS performance (update)
> 
> The wiki :: https://wikis.clusterfs.com/intra/index.php/LustreFS_performance
> 
> ~p
> 
> Vitaly Fertman wrote:
> > ****************************************************
> > 	LustreFS benchmarking methodology.
> > ****************************************************
> >
> >
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
-------------- next part --------------
A non-text attachment was scrubbed...
Name: example graphs.ods
Type: application/vnd.oasis.opendocument.spreadsheet
Size: 51672 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090323/d4bac167/attachment.ods>
