From: Nathan Rutman <Nathan.Rutman@Sun.COM>
Date: Tue, 09 Feb 2010 11:21:52 -0800
Subject: [Lustre-devel] server-side resending & bulk transfer
In-Reply-To: <002d01caa686$72c40d40$584c27c0$@com>
References: <20100205163524.GW236@granier.hd.free.fr>
	<002d01caa686$72c40d40$584c27c0$@com>
Message-ID: <0C48F4A2-5516-42C5-8520-7DC1B6BF08A1@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Feb 5, 2010, at 9:12 AM, Eric Barton wrote:

> Johann,
> 
> cc-ing lustre-devel.
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
> 
> Roll on the health network! :)
> 


Eric - this sounds like we can retry the LNetGet/Put whenever we want with
no ill effects (even if from client's point of view it has completed bulk, it will just
ignore a signal with unmatched matchbits, right?)  So it's "free" for us to try that
every time we e.g. send an early reply?  
For any LND LNetGet/Put does somehow indicate across the wire that the server
is ready for the bulk, so I'm making the bold assumption that re-calling that will
re-indicate server readiness (and in particular in the case where that original signal
got lost).  


>    Cheers,
>              Eric
> 
>> -----Original Message-----
>> From: Johann Lombardi [mailto:johann at sun.com]
>> Sent: 05 February 2010 4:35 PM
>> To: lustre-tech-leads at sun.com
>> Subject: server-side resending & bulk transfer
>> 
>> Hi,
>> 
>> As you know, the most important part of server-side resending is to resend
>> lock callbacks since a lost of such a message ends up with a client eviction
>> (except for glimpses which are resent indefinitely causing other problems).
>> 
>> That being said, another aspect is losing a message during bulk transfer, and
>> more particularly the start bulk signal issued by LNET.
>> Unlike lock callback rpcs, losing the start bulk signal is not fatal since
>> the bulk transfer will timeout on the server side, the request be dropped
>> and the client will resend after reconnection. This is indeed harmless,
>> but still causes slowdown which could be avoided according to LLNL if we
>> try to resend the start bulk signal (bug 21714). Brian Behlendorf's
>> proposal is to resend the start bulk signal after the first l_wait_event()
>> timeout in ost_brw_write(). However, we don't know if this is safe to do,
>> e.g. how does the client react if it receives duplicated start bulk signals?
>> 
>> Johann
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
