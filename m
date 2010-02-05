From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Fri, 5 Feb 2010 14:20:13 -0600
Subject: [Lustre-devel] server-side resending & bulk transfer
In-Reply-To: <002d01caa686$72c40d40$584c27c0$@com>
References: <20100205163524.GW236@granier.hd.free.fr>
	<002d01caa686$72c40d40$584c27c0$@com>
Message-ID: <20100205202013.GN1061@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 05, 2010 at 05:12:51PM +0000, Eric Barton wrote:
> On Feb 5, 2010, at 8:35 AM, Johann Lombardi wrote:
> > Unlike lock callback rpcs, losing the start bulk signal is not fatal since
> > the bulk transfer will timeout on the server side, the request be dropped
> > and the client will resend after reconnection. This is indeed harmless,
> > but still causes slowdown which could be avoided according to LLNL if we
> > try to resend the start bulk signal (bug 21714). Brian Behlendorf's
> > proposal is to resend the start bulk signal after the first l_wait_event()
> > timeout in ost_brw_write(). However, we don't know if this is safe to do,
> > e.g. how does the client react if it receives duplicated start bulk signals?
> 
> Yes, the server could retry the bulk if it times out and this
> will be safe for the client since its bulk buffer is auto-unlinked,
> so only 1 bulk PUT/GET can match it.  But if the problem happens
> on the way back to the server rather than the way out to the client,
> you're hosed since the bulk has completed from the client's POV.
> 
> This should be an exceptional circumstance - i.e. a router has
> actually failed - so I think it's better just to stick with the
> client retrying from scratch rather than tying down a server thread
> until it has decided whether there was a router failure or the
> client really crashed.

I agree that tying down a server thread on a long block is not a good
thing.  If the LLNL proposal (resend the start bulk signal) is on the
money, then the thing to do would be to create a queue and separate
service thread(s) to handle such resends.

> Roll on the health network! :)

Well, if the deadline here is on the order of 1s or thereabouts then the
health network isn't likely to help much because we're not going to get
sub-second dead node detection.  (Well, if we jack up the ping rate and
reduce the time-to-declare-death low enough, and make sure that HN
threads and messaging are suitably prioritized, then we might be able to
get sub-second dead node detection, but my gut feeling is that any
heuristic approach should wait for longer than 1s.)

Nico
-- 
