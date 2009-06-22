From: Brian Behlendorf <behlendorf1@llnl.gov>
Date: Mon, 22 Jun 2009 12:27:54 -0700
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
	stop blocking
In-Reply-To: <4A3FCB96.4010201@cray.com>
References: <4A3AC95A.10302@cray.com> <06b201c9f362$49015b20$db041160$@com>
	<4A3FCB96.4010201@cray.com>
Message-ID: <200906221227.57876.behlendorf1@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> However, it occurred to me that we would get the same behavior by simply
> tuning the server's recovery window down to whatever value we were going
> to assign  clnt_timeout.

Chris, for similiar reasons I put together a patch to do exactly this with a 
lustre server mount option.  There is a 1.6.x version in bugziilla 18948, 
attachment 23447, and a version pending inclusion in lustre 1.8.2.  It adds 
the following two options with the idea being they can be set to whatever is 
reasonable for your system.

recovery_time_soft= timeout
Allow 'timeout' seconds for clients to reconnect for recovery after a server
crash.  This timeout will be incrementally extended if it is about to expire
and the server is still handling new connections from recoverable clients.
The default soft recovery timeout is set to 300 seconds (5 minutes).

recovery_time_hard= timeout
The server will be allowed to incrementally extend its timeout up to a hard
maximum of 'timeout' seconds.  The default hard recovery timeout is set to
900 seconds (15 minutes).

-- 
Thanks,
Brian
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090622/a0be32dc/attachment.pgp>
