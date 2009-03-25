From: Robert Read <rread@sun.com>
Date: Wed, 25 Mar 2009 11:03:54 -0700
Subject: [Lustre-devel] some observations about metadata writeback cache
In-Reply-To: <m3prg5lerf.fsf@bzzz.home.net>
References: <m37i2x3mny.fsf@bzzz.home.net>
	<3AF28E58-CF74-49C9-AED7-86BDBB5EEC65@sun.com>
	<m3prg5lerf.fsf@bzzz.home.net>
Message-ID: <6EEE8418-1284-4908-ABA8-CF9446308AAB@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 25, 2009, at 09:59 , Alex Zhuravlev wrote:

>>>>>> Robert Read (RR) writes:
>
> RR> Hi Alex,
> RR> I'm trying to figure out how untrusted (what I'm calling simple)
> RR> clients and trusted WBC-type clients will work together at the  
> same
> RR> time. Simple clients will need to participate in the oldest  
> volatile
> RR> epoch calculation, but will need to retain operations for replay.
> RR> I've draw a simplified picture of how I think things are  
> beginning to
> RR> fit together, but more thought is needed here.
>
> RR> Simple clients
> RR>     - don't participate in global epochs
>
> hmm. if committed (in terms of transno) request can be reverted
> during global recovery, then even simple client has to retain
> request on replay list till it's stable in terms of epochs?

Yes, this is why these clients won't see the actual transno(s). Those  
would only be in the replay data blob the server returns with the  
reply. Instead, the MD server would send the epoch as the  transno in  
the reply to these clients.

>
> RR>     - don't have a node epoch or add epochs to messages
> RR>     - sends operations to MD server
> RR>     - replies include extended opaque "replay" data field
>
> probably we could simplify code a lot if we don't need to put
> reply into request in order to do replay? IOW, make all request's
> fields client-generated?

True, but a request could contain multiple replies (one for each  
update), and the client doesn't need to be aware of that. I was  
thinking it would be better if the server managed this field.  This  
mans the client can replay the request as it was originally sent and  
include the additional data at the end so the server can replay the  
updates in the correct order.

cheers,
robert
