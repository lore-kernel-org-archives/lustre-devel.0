From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Fri, 29 Aug 2008 11:46:36 -0700
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <20080828202541.GR3392@webber.adilger.int>
References: <200808201523.36720.alexander.zarochentsev@sun.com>
	<C4D1B2E1.575A%peter.braam@sun.com>
	<20080820192922.GG3392@webber.adilger.int>
	<200808221945.57702.alexander.zarochentsev@sun.com>
	<20080824020210.GY3392@webber.adilger.int> <48B6DC27.5020308@sun.com>
	<20080828202541.GR3392@webber.adilger.int>
Message-ID: <48B8440C.1000500@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Aug 28, 2008  10:11 -0700, Nathaniel Rutman wrote:
>   
>> Andreas Dilger wrote:
>>     
>>>>> I'd be thrilled if this was fixed so a normal shutdown did not do a
>>>>> "force" unmount and set the device read-only, because that would also
>>>>> avoid leaving the journal needing recovery.
>>>>>           
>> umount does either force or failover shutdown; failover sets readonly 
>> but force does not.  Test-framework regularly does both.  Andreas, if 
>> you want to avoid journal recovery, use umount -f.
>>     
>
> Well, issue is that with normal mount/unmount the filesystem is always
> dirty and needs journal recovery.  Also, for the DMU, where we will
> likely not have "read-only" support we need to be able to just block
> all client transactions and flush everything to disk, doing a normal
> shutdown.
>   
Perhaps we should remove the sync/readonly for failover shutdown, and 
instead add a OBD_FAIL_LOC (or just use the ioctl) for "power loss" 
failover testing.  One possible gotcha here is that sometimes it takes a 
long time for the umount to complete, and we want to make sure the 
failover partner does not try to start writing to the disk until the 
unmounting one is done.
