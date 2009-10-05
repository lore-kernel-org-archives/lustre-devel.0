From: Nic Henke <nic@cray.com>
Date: Mon, 05 Oct 2009 09:02:58 -0500
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <048601ca45ac$5cc33970$1649ac50$@com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com> <048601ca45ac$5cc33970$1649ac50$@com>
Message-ID: <4AC9FC92.5050602@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> What is it we really want to measure here?  Steady-state
> throughput or elapsed time to run a specific test (i.e.
> including ramp-up/ramp-down).
>   
Both :-)

The end-to-end performance is more interesting to me right now. The 
timing data is more accurate and we can run shorter tests that with 'lst 
stat' to get an idea of burst performance.  Having both methods is 
desirable to me.

> The intention behind the current stats command was to measure
> steady-state throughput - i.e.once the test batch(es?) have
> been started, a number of stat snapshots are taken until
> throughput settles.  That also probably allows tests to be
> run more quickly since they can be stopped immediately the
> steady state has been observed.
>
> Is that too hard to do with the current command set?
>   
It could be made cleaner and output the data to .csv, etc - but one can 
get a rough idea of steady state performance. The data will be more 
accurate once the timestamps for the data are sent over the wire instead 
of computed locally on the lst console node.

Nic
