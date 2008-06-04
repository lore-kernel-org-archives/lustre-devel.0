From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 04 Jun 2008 14:50:21 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <20080603185010.GB2961@webber.adilger.int>
References: <C4620704.5499%peter.braam@sun.com> <4843B259.40106@sun.com>
	<20080603185010.GB2961@webber.adilger.int>
Message-ID: <18502.29549.949260.391236@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger writes:
 > On Jun 02, 2008  12:42 +0400, Alex Zhuravlev wrote:
 > > there was an idea to control recovery postponing replies.
 > > can we use this idea for COS? instead of immediate sync
 > > we execute request, but put reply on a special queue. then
 > > reply is sent from the queue when all previous transno
 > > are committed (for COS w/o VBR). if there is no requests to
 > > be handled, but reply queue isn't empty server does sync.
 > 
 > Yes, this was proposed for the DMU OST, so that it can export
 > synchronous IO semantics to clients that do not know how to do
 > bulk IO recovery (i.e. all of them right now) without forcing
 > the DMU to limit the transaction group size too much.

This mechanism would be useful for other purposes too. For example, SOM
sometimes wants to reply only when certain transaction has committed and
currently this is implemented through an explicit sync. It seems that it
is generally better to make server IO as asynchronous as possible,
because this increases server throughput (even if at the expense of
individual request latency).

 > 
 > My proposal was that the OST service threads would perform the IO
 > in the normal manner until they were ready with the reply, but
 > instead of waiting in the thread context for the commit the RPC
 > request (with attached reply) would be put as private data into
 > a commit callback.  Once the commit callbacks are run (whether
 > because of transaction size, age, or explicit sync operation)
 > the RPC requests are put into a queue and sent by one or more
 > threads to the waiting clients.
 > 
 > This ties in fairly nicely with the network request scheduler, as
 > it can batch requests from the same or multiple clients in different
 > ways, and then "unplug" the device (sync the transaction).
 > 
 > Cheers, Andreas

Nikita.
