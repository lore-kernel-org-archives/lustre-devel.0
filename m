From: David Dillow <dillowda@ornl.gov>
Date: Tue, 29 Sep 2009 13:32:48 -0400
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4AC23B21.2030207@cray.com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com>
Message-ID: <1254245568.5827.5.camel@lap75545.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2009-09-29 at 11:51 -0500, Nic Henke wrote:
> I'm wondering if we couldn't add a new 'batch_stat' command. The idea is 
> that the client code will fill in the start/stop times for each test and 
> then after the test is done, 'batch_stat' would collect this data. The 
> collection would still be passive and a new command should minimize the 
> protocol changes. The per-test data would allow us to get accurate perf 
> numbers and also provide some data into how parallel the tests were, if 
> there are any unfairness issues, etc.

Along these lines, it would be nice if we could specify a run time for
each test rather than an amount of data to be transferred -- it makes it
easier to get aggregate bandwidth numbers, and often shows imbalances
nicely -- the node getting starved is the one that transfers less data.

It may also make sense to add a 'delay' parameter that causes each test
to wait a specified amount of time from the 'go' signal. This allows the
signal to propagate without running into congestion from the test,
helping to cause all of the clients to start the test closer to
simultaneously.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
