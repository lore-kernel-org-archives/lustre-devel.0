From: Robert Read <rread@sun.com>
Date: Tue, 23 Jun 2009 10:20:42 -0700
Subject: [Lustre-devel] Imperative Recovery - forcing failover
 server	stop blocking
In-Reply-To: <20090623145316.GC31668@webber.adilger.int>
References: <4A3AC95A.10302@cray.com>
	<447088AD-0C97-4314-A5AA-D7179C9C5C63@sun.com>
	<4A3C0CF2.1080809@cray.com>
	<06b201c9f362$49015b20$db041160$@com> <4A3FCB96.4010201@cray.com>
	<003301c9f401$1adb8af0$5092a0d0$@com>
	<20090623145316.GC31668@webber.adilger.int>
Message-ID: <3A1C008D-287F-42DE-B1F8-2D6D042A1138@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jun 23, 2009, at 07:53 , Andreas Dilger wrote:

> On Jun 23, 2009  13:49 +0100, Eric Barton wrote:
>> Yes, of course, you can just tune down the recovery window in the
>> knowledge that explicit notification has speeded the whole process of
>> client reconnection.  However if you have better knowledge about
>> client health than Lustre can have - e.g. hardware-specific health
>> monitoring, or just using the success/failure of the explicit
>> notification method itself - then why not use it to control exactly
>> when to stop waiting for dead clients?
>
> Yes, to restate this in a different way - the only way that Lustre  
> itself
> knows that some client will NOT be participating is after the  
> timeout has
> expired.  If there is some external mechanism that can inform Lustre  
> that
> one or more clients are dead and will not be participating in recovery
> then the recovery does not need to wait for the timeout.

The external mechanism should just evict the known dead clients from  
the server as soon as it discovers them so the server can begin  
recovery as soon as the live clients connect. Then we don't need to  
worry about the timeout.

robert
