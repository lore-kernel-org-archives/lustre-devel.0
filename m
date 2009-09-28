From: Isaac Huang <He.Huang@Sun.COM>
Date: Mon, 28 Sep 2009 13:35:54 -0400
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4ABBD78E.50506@cray.com>
References: <4ABBD78E.50506@cray.com>
Message-ID: <20090928173554.GA4911@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Sep 24, 2009 at 03:33:18PM -0500, Nic Henke wrote:
> Hello,
> 
> 	I'm hoping to get a few ideas on how we could modify LST to make doing 
> performance testing easier. Right now we can use "lst stat" to get a 
> rough idea of performance, but the timers are pretty rough and the data 
> is a snapshot.
> 
> 	Any ideas ? I've got cycles to do the coding, but not sure what would 
> be the best way to fit this into the existing LST framework.

There's some rough edges in the stat gathering code. First, the LST
console has no idea whether the tests have stopped, and that's why the
'lst stat' command by default loops until a ^C. Test clients could
return a counter for active test batches and when it drops to 0 all
tests on the client must have completed, but servers are passive and
have no idea whether clients are done or not.

The throughput calculation also could be inaccurate. IIRC, the console
just take a snapshot of stat counters on test nodes at a fixed
interval (1 second by default), and calculate the throughput as
changes in the successive counter snapshots divided by the interval.
But, apparently the interval at which the console sends 'get_stat'
requests does not equal the interval at which snapshots are taken on
test nodes - the 'get_stat' requests could be delayed on the path when
the network is stressed (something LST was designed to do), and even
worse they could be reordered in the presence of routers. One possible
solution would be to include timestamp in the 'get_stat' replies, and
calculate the throughput as diffs in counters divided by diffs in
timestamps. Since the console only cares about the changes in
timestamps, the test nodes clocks do not need to be in sync at all
(but they do need to be monotonic and be of a same resolution).

The test servers concurrently posts one passive buffer for each
request, so for each test request there's one LNetMDAttach and one
unlink operation and both operations need to grab the one big
LNET_LOCK therefore it could be possible that the server CPU becomes a
bottleneck before the network could be saturated. The solution is to,
instead of one request per buffer, post one big buffer that could
accommodate multiple requests to amortize the per buffer processing
costs.

Refining these rough edges might likely involve protocol changes. The
LST is not a production service so strict backward compatibility is
not necessary. I think it'd suffice to do a protocol version check at
the time of 'add_node' command and simply refuse to add a test node
whose protocol version is different than that of the console.

> BTW - the ability to dump CSV or some other text file with per-node and 
> per-group data would also be nice.

That's a good idea, then users could do whatever they'd like to the data.

Thanks,
Isaac
