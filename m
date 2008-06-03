From: Andreas Dilger <adilger@sun.com>
Date: Tue, 03 Jun 2008 12:50:10 -0600
Subject: [Lustre-devel] Commit on share
In-Reply-To: <4843B259.40106@sun.com>
References: <C4620704.5499%peter.braam@sun.com> <4843B259.40106@sun.com>
Message-ID: <20080603185010.GB2961@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 02, 2008  12:42 +0400, Alex Zhuravlev wrote:
> there was an idea to control recovery postponing replies.
> can we use this idea for COS? instead of immediate sync
> we execute request, but put reply on a special queue. then
> reply is sent from the queue when all previous transno
> are committed (for COS w/o VBR). if there is no requests to
> be handled, but reply queue isn't empty server does sync.

Yes, this was proposed for the DMU OST, so that it can export
synchronous IO semantics to clients that do not know how to do
bulk IO recovery (i.e. all of them right now) without forcing
the DMU to limit the transaction group size too much.

My proposal was that the OST service threads would perform the IO
in the normal manner until they were ready with the reply, but
instead of waiting in the thread context for the commit the RPC
request (with attached reply) would be put as private data into
a commit callback.  Once the commit callbacks are run (whether
because of transaction size, age, or explicit sync operation)
the RPC requests are put into a queue and sent by one or more
threads to the waiting clients.

This ties in fairly nicely with the network request scheduler, as
it can batch requests from the same or multiple clients in different
ways, and then "unplug" the device (sync the transaction).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
