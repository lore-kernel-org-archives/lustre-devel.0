From: Alex Zhuravlev <bzzz@sun.com>
Date: Wed, 25 Mar 2009 19:59:48 +0300
Subject: [Lustre-devel] some observations about metadata writeback cache
In-Reply-To: <3AF28E58-CF74-49C9-AED7-86BDBB5EEC65@sun.com>
References: <m37i2x3mny.fsf@bzzz.home.net>
	<3AF28E58-CF74-49C9-AED7-86BDBB5EEC65@sun.com>
Message-ID: <m3prg5lerf.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> Robert Read (RR) writes:

 RR> Hi Alex,
 RR> I'm trying to figure out how untrusted (what I'm calling simple)
 RR> clients and trusted WBC-type clients will work together at the same
 RR> time. Simple clients will need to participate in the oldest volatile
 RR> epoch calculation, but will need to retain operations for replay.
 RR> I've draw a simplified picture of how I think things are beginning to
 RR> fit together, but more thought is needed here.

 RR> Simple clients
 RR>     - don't participate in global epochs

hmm. if committed (in terms of transno) request can be reverted
during global recovery, then even simple client has to retain
request on replay list till it's stable in terms of epochs?

 RR>     - don't have a node epoch or add epochs to messages
 RR>     - sends operations to MD server
 RR>     - replies include extended opaque "replay" data field

probably we could simplify code a lot if we don't need to put
reply into request in order to do replay? IOW, make all request's
fields client-generated?


thanks, Alex
