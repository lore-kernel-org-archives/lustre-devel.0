From: Eric Barton <eeb@sun.com>
Date: Mon, 05 Oct 2009 12:09:52 +0100
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4AC23B21.2030207@cray.com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com>
Message-ID: <048601ca45ac$5cc33970$1649ac50$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

What is it we really want to measure here?  Steady-state
throughput or elapsed time to run a specific test (i.e.
including ramp-up/ramp-down).

The intention behind the current stats command was to measure
steady-state throughput - i.e.once the test batch(es?) have
been started, a number of stat snapshots are taken until
throughput settles.  That also probably allows tests to be
run more quickly since they can be stopped immediately the
steady state has been observed.

Is that too hard to do with the current command set?


    Cheers,
              Eric
