From: Eric Barton <eeb@Sun.COM>
Date: Mon, 22 Jun 2009 18:53:01 +0100
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <4A3C0CF2.1080809@cray.com>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
	<4A3C0CF2.1080809@cray.com>
Message-ID: <06b201c9f362$49015b20$db041160$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Chris,

Comment inline...

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Chris Horn
> Sent: 19 June 2009 11:11 PM
> To: lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] Imperative Recovery - forcing failover server stop blocking
> 
> Oops, I forgot to cc lustre-devel.
> 
> Johann Lombardi wrote:
> 
> > > On Jun 19, 2009, at 1:10 AM, Chris Horn wrote:
> >
> >> >> It seems as though an ability to short circuit is only going to be
> >> >> useful if we can distinguish between the case where we only need a short
> >> >> recovery window vs. the case where we need that extra time.  My question
> >> >> is, what are the use cases where this applies?
> >> >>
> >> >> My intuition is the following:
> >> >> Case 1:  x/y clients which are dead, (y-x)/y clients connected to the
> >> >> backup server (all clients that can connect have done so).  We want to
> >> >> go ahead and short circuit.
> >>
> > >
> > > That's the 2nd aspect of imperative recovery. We want to notify the
> > > server when all clients that were supposed to reconnect should
> > > have done so already. Basically, the idea is to tell the server that
> > > no new clients will reconnect now and that it is not needed to wait
> > > any longer for new clients to join (the x clients).
> >
> I just want to verify that in order to use this 2nd aspect of imperative
> recovery we need some method of determining client health, yes?

Yes.  

Consider a utility that runs on a client to notify it to reconnect to a
failover server, and which completes with a success status only when the
client has reconnected successfully.

If you run this utility on all clients after starting a failover server,
you can notify the server to close the recovery window once all instances have
completed since that tells you that all clients are healthy and ready to
participate in recovery.

Of course, you can decide to stop waiting and proceed with the server
notification at any time you like.  You can base this decision on a timeout,
knowing how many clients have reconnected successfully, or any other criterion
you chose - i.e. you are now the effective arbiter of client health.

    Cheers,
              Eric
