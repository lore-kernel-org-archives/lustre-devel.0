From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 01 Apr 2009 08:13:09 -0700
Subject: [Lustre-devel] Start the MGS first?
In-Reply-To: <1238011240.6090.16.camel@pc.interlinx.bc.ca>
References: <49CA8A73.9080103@sun.com>
	<1238011240.6090.16.camel@pc.interlinx.bc.ca>
Message-ID: <49D38485.3090801@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian J. Murrell wrote:
> On Wed, 2009-03-25 at 12:48 -0700, Nathaniel Rutman wrote:
>   
>> As of Lustre 1.6, servers can be started in any order (after the initial registration at first startup).  Internally, this required significant bending of our connection rules, and with a move toward ZFS becomes even more burdensome.  
>> So my question to the Lustre community is this: would anyone strenuously object to a startup ordering requirement that the MGS must be started before any other servers?  
>> This would probably be in the Lustre 3.0 timeframe.  It is also likely that we will have to divorce the MGS and MDT onto separate devices -- no more "combo" MDT/MGSes. 
>>     
>
> I'll ask before anyone else does... would this require the MGS be
> available at any time a server (or client?) needs to start rather than
> the optional behaviour (for anything but first time server starts) that
> we currently enjoy?  IOW, does this make the MGS a much more critical
> component of the filesystem than it is currently?
>   
yes.    It's already required for client starts.  What we would do is 
have the MDT / OST server mounts block until the MGS is up, probably 
with a timeout.
And yes, this will be some amount less flexible than the current startup 
order, but we gain advantages from it - simplified import states, more 
centralized configuration, single-path disk access.  The question is how 
burdensome really will this limitation be.  So far I have not heard very 
much gnashing of teeth and rending of garments.
