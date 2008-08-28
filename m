From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 28 Aug 2008 10:11:03 -0700
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <20080824020210.GY3392@webber.adilger.int>
References: <200808201523.36720.alexander.zarochentsev@sun.com>
	<C4D1B2E1.575A%peter.braam@sun.com>
	<20080820192922.GG3392@webber.adilger.int>
	<200808221945.57702.alexander.zarochentsev@sun.com>
	<20080824020210.GY3392@webber.adilger.int>
Message-ID: <48B6DC27.5020308@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Aug 22, 2008  19:45 +0400, Alexander Zarochentsev wrote:
>   
>> On 20 August 2008 23:29:22 Andreas Dilger wrote:
>>     
>>> On Aug 20, 2008  11:39 -0600, Peter J. Braam wrote:
>>>       
>>>> If I remember correctly the flush is only there to try to reduce
>>>> rollback. However, given that failover may happen on a system where
>>>> the software is not fully responsive, one could question the wisdom
>>>> of this reduction.  In any case having more replay due to more
>>>> rollback is harmless.
>>>>         
IIRC one other reason for the flush is that loopback disks tend not to 
"really" flush everything to disk when asked, and additional sync calls 
seem to help.  So beware when running loopback disks...
>>> One major caveat is that with mountconf we ALWAYS mark the device as
>>> "readonly" when it is being unmounted.
>>> If we don't have the sync 
>>> there I fear data loss after a clean server unmount, when all clients
>>> are also being unmounted and cannot do replay.
>>>
>>> I'd be thrilled if this was fixed so a normal shutdown did not do a
>>> "force" unmount and set the device read-only, because that would also
>>> avoid leaving the journal needing recovery.
>>>       
>
umount does either force or failover shutdown; failover sets readonly 
but force does not.  Test-framework regularly does both.  Andreas, if 
you want to avoid journal recovery, use umount -f.
Really read-only is intended to simulate a power loss, so I think sync 
before it is a bit of a cheat.    Having said that, I think there were 
real issues that prompted us to include the sync in the first place, and 
some heavy recovery testing (including loopback devs) is in order if it 
is removed.
