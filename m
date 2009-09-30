From: David Dillow <dillowda@ornl.gov>
Date: Wed, 30 Sep 2009 09:53:15 -0400
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4AC24BB1.8040502@cray.com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com> <1254245568.5827.5.camel@lap75545.ornl.gov>
	<4AC24BB1.8040502@cray.com>
Message-ID: <1254318795.3114.1.camel@lap75545.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2009-09-29 at 14:02 -0400, Nic Henke wrote:
> David Dillow wrote:
> > Along these lines, it would be nice if we could specify a run time for
> > each test rather than an amount of data to be transferred -- it makes it
> > easier to get aggregate bandwidth numbers, and often shows imbalances
> > nicely -- the node getting starved is the one that transfers less data.
> >   
> > It may also make sense to add a 'delay' parameter that causes each test
> > to wait a specified amount of time from the 'go' signal. This allows the
> > signal to propagate without running into congestion from the test,
> > helping to cause all of the clients to start the test closer to
> > simultaneously.
> >   
> 
> Interesting - can you elaborate, perhaps in the form of a patch  ? :-) I 
> like both ideas, but not signing up to code them just yet.

Maybe, but it is going to be well down the list -- I owe Oleg a large
amount of testing before I think of doing anything else. :)
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
