From: Eric Barton <eeb@sun.com>
Date: Wed, 04 Jun 2008 14:25:10 +0100
Subject: [Lustre-devel] hiding non-fatal communications errors
Message-ID: <018701c8c646$6a6d56a0$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Something for recovery experts...

Communications may timeout for non-fatal reasons e.g...

1. Adaptive timeouts were too aggressive (e.g. if server load has
   suddenly become extreme).

2. An LNET router has failed but one or more of its peers hasn't
   detected this yet.

When a lustre client times out an RPC it sent to a server, it (a) allows
pending signals to be delivered (i.e. you can now ^C the process doing
the I/O) and (b) tries to reconnect and/or fail over.  If it reconnects
and confirms that the server has not rebooted, the RPC is resent and
may now succeed.

This should work in all "normal" RPCs (i.e. all RPCs apart from ldlm
callbacks (ASTs)) since the server knows whether it actually processed
the RPC or not and can handle the resent request appropriately.

However I think there is a problem if the RPC is an ldlm callback.  In
this case, the lustre server sends the RPC to the lustre client and
AFAIK the request is not resent if it times out.  If the request is a
blocking AST, the lustre client isn't notified to clean its cache and
cancel locks - and it risks being evicted.

How should this be handled?
