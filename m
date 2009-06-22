From: Chris Horn <hornc@cray.com>
Date: Mon, 22 Jun 2009 13:21:10 -0500
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <06b201c9f362$49015b20$db041160$@com>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
	<4A3C0CF2.1080809@cray.com> <06b201c9f362$49015b20$db041160$@com>
Message-ID: <4A3FCB96.4010201@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton wrote:
> Consider a utility that runs on a client to notify it to reconnect to a
> failover server, and which completes with a success status only when the
> client has reconnected successfully.
>   
Would this be equivalent to monitoring the "completed_clients" field of
the recovery_status proc file?
> If you run this utility on all clients after starting a failover server,
> you can notify the server to close the recovery window once all instances have
> completed since that tells you that all clients are healthy and ready to
> participate in recovery.
>   
Won't the server already begin replay by this time, since it has
received connections from all clients?  Thus rendering our notification
to the server (to close the recovery window) redundant?
> Of course, you can decide to stop waiting and proceed with the server
> notification at any time you like.  You can base this decision on a timeout,
> knowing how many clients have reconnected successfully, or any other criterion
> you chose - i.e. you are now the effective arbiter of client health.
>   
Our initial plan was to do just this.  We would have a proxy running on
the bootnode to aggregate client responses.  It would wait some
configurable timeout period, say clnt_timeout, and if it received a # of
responses equal to obd->obd_max_recoverable_clients, it would go ahead
and notify the server to stop waiting for responses immediately (though
this is the situation described in the last comment).  If the timeout
expired it would notify the server to stop waiting.  However, it
occurred to me that we would get the same behavior by simply tuning the
server's recovery window down to whatever value we were going to assign
clnt_timeout.  It seemed we were going through an awful lot of trouble
to gain a tunable recovery_window.  I'm not sure if this is a result of
our choosing poor criterion upon which to notify the server to stop
waiting, or if there is something else (a use case perhaps) that I'm
missing.
>     Cheers,
>               Eric
>
>
>   
