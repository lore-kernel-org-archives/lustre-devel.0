From: Eric Barton <eeb@sun.com>
Date: Thu, 05 Jun 2008 00:41:49 +0100
Subject: [Lustre-devel] hiding non-fatal communications errors
In-Reply-To: <C46C546F.57D1%peter.braam@sun.com>
References: <018701c8c646$6a6d56a0$0281a8c0@ebpc>
	<C46C546F.57D1%peter.braam@sun.com>
Message-ID: <02f901c8c69c$8ede99d0$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> -----Original Message-----
> From: Peter.Braam at Sun.COM [mailto:Peter.Braam at Sun.COM] 
> Sent: 04 June 2008 10:17 PM
> To: Eric Barton; 'Lustre Development Mailing List'
> Subject: Re: [Lustre-devel] hiding non-fatal communications errors
> 
> Andreas has been suggesting re-transmission of these callback (aka AST) RPCs
> for years.  If we think it through carefully, it might be a simple solution.

Yes - carefully is the watchword - I suspect lock callback RPCs (aka ASTs)
have some fundamentally different properties.  Nathan and I seemed to
touch on this when we last chatted about related AT issues.

Any volunteers to s/we/me/ ?

> 
> Peter
> 
> 
> On 6/4/08 6:25 AM, "Eric Barton" <eeb@sun.com> wrote:
> 
> > Something for recovery experts...
> > 
> > Communications may timeout for non-fatal reasons e.g...
> > 
> > 1. Adaptive timeouts were too aggressive (e.g. if server load has
> >    suddenly become extreme).
> > 
> > 2. An LNET router has failed but one or more of its peers hasn't
> >    detected this yet.
> > 
> > When a lustre client times out an RPC it sent to a server, it (a) allows
> > pending signals to be delivered (i.e. you can now ^C the process doing
> > the I/O) and (b) tries to reconnect and/or fail over.  If it reconnects
> > and confirms that the server has not rebooted, the RPC is resent and
> > may now succeed.
> > 
> > This should work in all "normal" RPCs (i.e. all RPCs apart from ldlm
> > callbacks (ASTs)) since the server knows whether it actually processed
> > the RPC or not and can handle the resent request appropriately.
> > 
> > However I think there is a problem if the RPC is an ldlm callback.  In
> > this case, the lustre server sends the RPC to the lustre client and
> > AFAIK the request is not resent if it times out.  If the request is a
> > blocking AST, the lustre client isn't notified to clean its cache and
> > cancel locks - and it risks being evicted.
> > 
> > How should this be handled?
> > 
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at lists.lustre.org
> > http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> 
> 
