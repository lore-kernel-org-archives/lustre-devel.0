From: Eric Barton <eeb@sun.com>
Date: Tue, 23 Jun 2009 13:49:53 +0100
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <4A3FCB96.4010201@cray.com>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
	<4A3C0CF2.1080809@cray.com>
	<06b201c9f362$49015b20$db041160$@com> <4A3FCB96.4010201@cray.com>
Message-ID: <003301c9f401$1adb8af0$5092a0d0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Chris,

> Eric Barton wrote:
> > Consider a utility that runs on a client to notify it to reconnect
> > to a failover server, and which completes with a success status
> > only when the client has reconnected successfully.
>
> Would this be equivalent to monitoring the "completed_clients" field
> of the recovery_status proc file?

No, this is for accounting clients that have actually completed
recovery, not clients which have reconnected and are therefore ready
to participate in recovery - you'd want 'connected_clients' for that.

But actually, counting reconnected clients is only half the story.
Currently clients don't even start to participate in recovery until
they detect an error communicating with the failed server - i.e. after
a timeout _and_ a failed reconnection attempt.  This utility
eliminates this latency by notifying the client explicitly to
reconnect NOW.

> > If you run this utility on all clients after starting a failover
> > server, you can notify the server to close the recovery window
> > once all instances have completed since that tells you that all
> > clients are healthy and ready to participate in recovery.
>
> Won't the server already begin replay by this time, since it has
> received connections from all clients?  Thus rendering our
> notification to the server (to close the recovery window) redundant?

Yes, in the optimistic event that all clients reconnected.  

> > Of course, you can decide to stop waiting and proceed with the
> > server notification at any time you like.  You can base this
> > decision on a timeout, knowing how many clients have reconnected
> > successfully, or any other criterion you chose - i.e. you are now
> > the effective arbiter of client health.
>
> Our initial plan was to do just this.  We would have a proxy running
> on the bootnode to aggregate client responses.  It would wait some
> configurable timeout period, say clnt_timeout, and if it received a
> # of responses equal to obd->obd_max_recoverable_clients, it would
> go ahead and notify the server to stop waiting for responses
> immediately (though this is the situation described in the last
> comment).  If the timeout expired it would notify the server to stop
> waiting.  However, it occurred to me that we would get the same
> behavior by simply tuning the server's recovery window down to
> whatever value we were going to assign clnt_timeout.  It seemed we
> were going through an awful lot of trouble to gain a tunable
> recovery_window.  I'm not sure if this is a result of our choosing
> poor criterion upon which to notify the server to stop waiting, or
> if there is something else (a use case perhaps) that I'm missing.

Yes, of course, you can just tune down the recovery window in the
knowledge that explicit notification has speeded the whole process of
client reconnection.  However if you have better knowledge about
client health than Lustre can have - e.g. hardware-specific health
monitoring, or just using the success/failure of the explicit
notification method itself - then why not use it to control exactly
when to stop waiting for dead clients?

-- 

        Cheers,
                   Eric
