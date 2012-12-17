From: Liu, Xuezhao <Xuezhao.Liu@emc.com>
Date: Mon, 17 Dec 2012 01:52:35 -0500
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <201212170544.qBH5iOuM019618@hedwig.cmf.nrl.navy.mil>
References: <2BD6B3FE-788D-4B27-8759-FFCB2EC612D6@intel.com>
	<201212170544.qBH5iOuM019618@hedwig.cmf.nrl.navy.mil>
Message-ID: <AE8E737235CD0640B291384BFC2D8A354A3A7348@MX10A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Current the libcfs cleanup is mainly done by replacing kinds of libcfs calls with direct kernel primitives, we can implement the portable layer on other OS with the same name as Linux.
I think the real concern is that on other OS there is possible some kernel primitives have the same name a Linux kernel but with different behavior/parameters, that will cause either compiling broken or running crashing etc.
I don't have the full list of the above intersecting case, but it should be very rare right? We can build a separate patch( which should be small) for those intersecting cases for other OS, and I guess that patch need to be maintained separately.

And lustre CLIO is structured that all OS-dependent glue is supposed to be handled in the topmost layer (VVP for linux client). For Mac or Windows's native client, it is possibly just implement a new thin top layer if interests really raised on those platform? This could reduce the possibility of the above intersecting cases.

Thanks,
Xuezhao
-----Original Message-----
From: Ken Hornstein [mailto:kenh at cmf.nrl.navy.mil] 
Sent: 2012?12?17? 13:44
To: WC-Discuss; lustre-devel at lists.lustre.org
Subject: Re: [Lustre-devel] [wc-discuss] Important changes to libcfs primitives usage.

>While I would be thrilled if there was a native MacOS and Windows 
>client for Lustre, realistically there is nothing today.  The MacOS 
>client is not maintained, and the Windows client is stick inside Oracle.
>
>In contrast, only the Linux client is on use today, so it makes sense 
>to focus effort on this instead of spending time on maintaining 
>portability code that is not useful to us.
>
>If the other clients were usable, perhaps a different decision would be 
>made.

So, let me speak to that a bit since I was the one who did the MacOS X port which has been langunishing.

Andreas is completely right that 90% of libcfs library for Linux at least is adding to kernel internal interfaces a "cfs_" prefix.  So that part at least isn't going to change the issues with porting Lustre to other operating systems; you have to pretty much emulate a whole pile of Linux interfaces.
So that doesn't really worry me in terms of future portability.

What _does_ concern me is that to be portable Lustre needs some code in the generic side of things.  Example: locks in MacOS X are done via allocated memory, so you need to release that memory when you're done.  Lustre never does this (because it's not needed under Linux since locks use statically allocated memory).  So is it going to be possible in the future to put generic code to aid portabiliy in Lustre?  I don't know.

Personally, I think putting Lustre in the Linux kernel is a terrible idea, but since I was obviously in the minority on that one I figured there was no reason to really say anything about it.  Also, it's hard for me to voice objections about possible MacOS X portability issues when I can't dedicate any resources to cleaning up the MacOS X port.

--Ken
