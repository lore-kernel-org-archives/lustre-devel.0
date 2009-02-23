From: Nicholas Henke <nic@cray.com>
Date: Mon, 23 Feb 2009 17:53:31 -0600
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <49A32851.50803@sun.com>
References: <49A18841.7030200@cray.com>
	<56B06EF4-AAF5-448C-96C0-55E5E9A1AA44@sun.com>
	<010b01c995ff$43083420$c9189c60$@com> <49A32851.50803@sun.com>
Message-ID: <49A336FB.1040908@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

di wang wrote:
> Hello,
> Eric Barton wrote:
>> Although I could agree that there should be levels of abstraction
>> above libcfs, it is, de facto, the place we put _all_ generic code
>> - not just stateless porting primitives, but everything that can be
>> used everywhere.
>>
>> I don't actually think of obd_fail_check as inexorably bound with
>> /proc.  But since that's the current implementation, it's probably
>> my oversight not to have shared that sense of direction.
>>
>> Nic, is the patch totally /proc - centric?  Wangdi is doing the work
>> to remove /proc-ness and make our tuneables, configurables and monitoring
>> more portable.  He needs to be involved...

Not totally, no - just the user-space data manipulation. Once that variable is 
set, the code is pretty agnostic.

> Yes, after we have our own /proc stuff in lustre, which might be land to 
> HEAD in 2 or 3 weeks. All the new proc stuff is implemented in libcfs 
> layer, then we will move as much as obd proc stuff(obd lprocfs layer) to 
> libcfs layer, then they(include obd_fail_check) can be shared with LNET.
> 

Is there a branch name I could checkout to look at this ? I'd like to make sure 
the fail_loc move would be easy to tie into that.

> The only difference for those sysctl parameters is that you may not use 
> /etc/sysctl.conf to control them anymore, and lctl set_param is the only 
> interface here.
> 
> Actually, you can also move this now. but it means you need move those 
> obd proc api to libcfs layer,  which  might  not  be  small  amount  of  
> work.

It isn't too bad - they use the CFS_PROC_PROTO and not all of the lprocfs_XXX() 
functionality.

It should like this would have a limited lifetime in 1.6.X and 1.8.X, but I'm 
fine with that. That gives us a bit of time :-)

Nic
