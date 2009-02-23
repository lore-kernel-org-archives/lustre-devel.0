From: di wang <di.wang@sun.com>
Date: Mon, 23 Feb 2009 17:50:57 -0500
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <010b01c995ff$43083420$c9189c60$@com>
References: <49A18841.7030200@cray.com>
	<56B06EF4-AAF5-448C-96C0-55E5E9A1AA44@sun.com>
	<010b01c995ff$43083420$c9189c60$@com>
Message-ID: <49A32851.50803@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
Eric Barton wrote:
> Although I could agree that there should be levels of abstraction
> above libcfs, it is, de facto, the place we put _all_ generic code
> - not just stateless porting primitives, but everything that can be
> used everywhere.
>
> I don't actually think of obd_fail_check as inexorably bound with
> /proc.  But since that's the current implementation, it's probably
> my oversight not to have shared that sense of direction.
>
> Nic, is the patch totally /proc - centric?  Wangdi is doing the work
> to remove /proc-ness and make our tuneables, configurables and monitoring
> more portable.  He needs to be involved...
>
>   
Yes, after we have our own /proc stuff in lustre, which might be land to 
HEAD in 2 or 3 weeks. All the new proc stuff is implemented in libcfs 
layer, then we will move as much as obd proc stuff(obd lprocfs layer) to 
libcfs layer, then they(include obd_fail_check) can be shared with LNET.

The only difference for those sysctl parameters is that you may not use 
/etc/sysctl.conf to control them anymore, and lctl set_param is the only 
interface here.

Actually, you can also move this now. but it means you need move those 
obd proc api to libcfs layer,  which  might  not  be  small  amount  of  
work.

Thanks
WangDi
>     Cheers,
>               Eric
>
>   
