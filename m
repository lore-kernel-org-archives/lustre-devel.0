From: Eric Barton <eeb@sun.com>
Date: Fri, 05 Feb 2010 17:12:51 +0000
Subject: [Lustre-devel] server-side resending & bulk transfer
In-Reply-To: <20100205163524.GW236@granier.hd.free.fr>
References: <20100205163524.GW236@granier.hd.free.fr>
Message-ID: <002d01caa686$72c40d40$584c27c0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Johann,

cc-ing lustre-devel.

Yes, the server could retry the bulk if it times out and this
will be safe for the client since its bulk buffer is auto-unlinked,
so only 1 bulk PUT/GET can match it.  But if the problem happens
on the way back to the server rather than the way out to the client,
you're hosed since the bulk has completed from the client's POV.

This should be an exceptional circumstance - i.e. a router has
actually failed - so I think it's better just to stick with the
client retrying from scratch rather than tying down a server thread
until it has decided whether there was a router failure or the
client really crashed.

Roll on the health network! :)

    Cheers,
              Eric

> -----Original Message-----
> From: Johann Lombardi [mailto:johann at sun.com]
> Sent: 05 February 2010 4:35 PM
> To: lustre-tech-leads at sun.com
> Subject: server-side resending & bulk transfer
> 
> Hi,
> 
> As you know, the most important part of server-side resending is to resend
> lock callbacks since a lost of such a message ends up with a client eviction
> (except for glimpses which are resent indefinitely causing other problems).
> 
> That being said, another aspect is losing a message during bulk transfer, and
> more particularly the start bulk signal issued by LNET.
> Unlike lock callback rpcs, losing the start bulk signal is not fatal since
> the bulk transfer will timeout on the server side, the request be dropped
> and the client will resend after reconnection. This is indeed harmless,
> but still causes slowdown which could be avoided according to LLNL if we
> try to resend the start bulk signal (bug 21714). Brian Behlendorf's
> proposal is to resend the start bulk signal after the first l_wait_event()
> timeout in ost_brw_write(). However, we don't know if this is safe to do,
> e.g. how does the client react if it receives duplicated start bulk signals?
> 
> Johann
