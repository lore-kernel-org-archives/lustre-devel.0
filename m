From: Isaac Huang <He.Huang@Sun.COM>
Date: Thu, 08 Oct 2009 15:42:25 -0400
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4AC23B21.2030207@cray.com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com>
Message-ID: <20091008194225.GX4767@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 29, 2009 at 11:51:45AM -0500, Nic Henke wrote:
>   ......
> > The test servers concurrently posts one passive buffer for each
> > request, so for each test request there's one LNetMDAttach and one
> > unlink operation and both operations need to grab the one big
> > LNET_LOCK therefore it could be possible that the server CPU becomes a
> > bottleneck before the network could be saturated. The solution is to,
> > instead of one request per buffer, post one big buffer that could
> > accommodate multiple requests to amortize the per buffer processing
> > costs.
> >   
> If we added timestamps to the data, the processing time & buffer sizing 
> would be less of an issue - it wouldn't factor into the accuracy of the 
> numbers are are gathering.

Probably not. The timestamps affect only the stat gathering RPCs which
should be far out numbered by the test RPCs (loop x concurrency x
test_client_count, for each test server).

Isaac
