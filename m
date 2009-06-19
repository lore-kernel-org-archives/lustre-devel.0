From: Chris Horn <hornc@cray.com>
Date: Fri, 19 Jun 2009 17:10:58 -0500
Subject: [Lustre-devel] Imperative Recovery - forcing failover server
 stop blocking
In-Reply-To: <447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
Message-ID: <4A3C0CF2.1080809@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oops, I forgot to cc lustre-devel.

Johann Lombardi wrote:

> > On Jun 19, 2009, at 1:10 AM, Chris Horn wrote:
>   
>> >> It seems as though an ability to short circuit is only going to be
>> >> useful if we can distinguish between the case where we only need a short
>> >> recovery window vs. the case where we need that extra time.  My question
>> >> is, what are the use cases where this applies?
>> >>
>> >> My intuition is the following:
>> >> Case 1:  x/y clients which are dead, (y-x)/y clients connected to the
>> >> backup server (all clients that can connect have done so).  We want to
>> >> go ahead and short circuit.
>>     
> >
> > That's the 2nd aspect of imperative recovery. We want to notify the
> > server when all clients that were supposed to reconnect should
> > have done so already. Basically, the idea is to tell the server that
> > no new clients will reconnect now and that it is not needed to wait
> > any longer for new clients to join (the x clients).
>   
I just want to verify that in order to use this 2nd aspect of imperative
recovery we need some method of determining client health, yes?


Chris Horn
