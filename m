From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Wed, 5 May 2010 11:26:58 -0400
Subject: [Lustre-devel] lnet NAT friendliness
In-Reply-To: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
References: <201005051238.o45Ccwtt006732@hedwig.cmf.nrl.navy.mil>
Message-ID: <E605710A-EB8D-4B51-8B1D-F3FECEA67045@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On May 5, 2010, at 8:38 AM, Ken Hornstein wrote:

>> LNet requires destination address of message to be same with address of 
>> LNet NI (unless it's a router), I'm afraid it's not easy to make it  be 
>> tunable.
>> 
>> I would suggest to run lustre (lnet) router on the gateway (if your 
>> gateway is Linux...)
> Well, that's not really feasible, because a) many times we don't
> control the gateway (think sitting in Starbucks; and while some people
> would say that they don't want to use Lustre from Starbucks, I would
> say, "Why not?"; with Kerberos authentication, I think it would be
> perfectly reasonable), and b) even if you control the gateway, that
> doesn't really scale, because while that might work for one person,
> I don't see how you would do it for more than one person (how would
> you configure the routing back if more than one person are using the
> same NAT address range?).
> I admit I have no love for NAT and I would prefer it if we were living
> in a world where the end-to-end principle worked everywhere, but that
> battle was lost years ago.

I would think using VPN from outside into your Lustre-supplying LAN should
be enough to work around this problem somewhat easily with no code changes.

Also provides an encrypted secure channel as a bonus.

Bye,
    Oleg
