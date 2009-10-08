From: Isaac Huang <He.Huang@Sun.COM>
Date: Thu, 08 Oct 2009 15:36:43 -0400
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <1254245568.5827.5.camel@lap75545.ornl.gov>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com> <1254245568.5827.5.camel@lap75545.ornl.gov>
Message-ID: <20091008193643.GW4767@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 29, 2009 at 01:32:48PM -0400, David Dillow wrote:
> On Tue, 2009-09-29 at 11:51 -0500, Nic Henke wrote:
> > I'm wondering if we couldn't add a new 'batch_stat' command. The idea is 
> > that the client code will fill in the start/stop times for each test and 
> > then after the test is done, 'batch_stat' would collect this data. The 
> > collection would still be passive and a new command should minimize the 
> > protocol changes. The per-test data would allow us to get accurate perf 
> > numbers and also provide some data into how parallel the tests were, if 
> > there are any unfairness issues, etc.
> 
> Along these lines, it would be nice if we could specify a run time for
> each test rather than an amount of data to be transferred -- it makes it
> easier to get aggregate bandwidth numbers, and often shows imbalances
> nicely -- the node getting starved is the one that transfers less data.

This would be a very useful feature. We're working on to add LST tests
to our automatic tests, where we met a problem that we could never
tell how long the test would run by looking at '--loop' and
'--concurrency'.

The LST already implemented a timer mechanism which is good at second
resolution, which should suffice for controlling test run time.

Isaac
