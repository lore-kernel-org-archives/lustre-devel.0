From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Fri, 29 Feb 2008 13:38:21 -0800
Subject: [Lustre-devel] Thoughts on benchmarking
In-Reply-To: <20080229211014.GQ2997@webber.adilger.int>
References: <47C336C8.4090108@lbl.gov>
	<20080229211014.GQ2997@webber.adilger.int>
Message-ID: <47C87B4D.7070803@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Howdy Andreas,
   Long time no electron :)

   The work on Franklin (NERSC's shiny new XT4) uses the Lustre 
delivered and supported by Cray.  I believe it's 1.6.x, but I'd have to 
ask around to get the details.  Is there a way to dig the Lustre version 
out of a client?  I'm at a workshop now.  I'll try to address this next 
week.  Note that they updated things on Franklin earlier in February. 
After that we saw a substantial performance increase.  The details of 
what changed have not been communicated to be.  Sometime in the near 
future I'll be interested to follow up on the work I've written about. 
Feel free to contribute suggestions of tests you'd be interested in.
Cheers,
Andrew


Andreas Dilger wrote:
> On Feb 28, 2008  20:20 -0700, Peter J. Braam wrote:
>> I see some worrying dips in the graphs - can our I/O specialists comment on
>> which ones are understood and which are not?
> 
> I think one of the major problems that Andrew discusses at the end of
> the test runs is described in bug 7365 "Poor performance when files share
> an OSC".  I didn't see anywhere in the paper which version of Lustre was
> being tested, but I know we did some work to improve the round-robin
> allocator to make it more uniform in more recent releases, up to a
> certain extent.
> 
> That said, getting completely uniform file distribution will still need
> some effort, because the MDS doesn't do any correlation between create
> requests (e.g. from a single job, from a single client, etc).
> 
>> On 2/25/08 2:44 PM, "Andrew C. Uselton" <acuselton@lbl.gov> wrote:
>>>   I'd been in conversation with Cliff White over the last few weeks, and
>>> he'd expressed an interest in having me post a draft of a report I've
>>> been working on.  If you've already heard of it here it is.  For those
>>> who hadn't I'll try to describe it briefly.
>>>
>>>   In December I assisted with some Lustre benchmark tests on the
>>> Franklin Cray XT here at NERSC.  Since then I've tried to summarize our
>>> analysis and results.  The attached pdf is a draft of that summary.  The
>>> introduction is almost completely useless, so feel free to skip (unless
>>> you want to have a laugh at the author's expense).  Section 3 has the
>>> main details about what we observed and what we thought about it.
>>> Section 2 may be amusing for those (like me) who care about methodology.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
