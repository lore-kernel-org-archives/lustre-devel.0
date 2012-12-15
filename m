From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Sat, 15 Dec 2012 10:27:29 +0400
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <1882637210201641A747464075FFC64906D355@MX101CL02.corp.emc.com>
References: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
	<B96EB845-0B4F-42DD-9CDF-FDF358A1BD0F@xyratex.com>
	<1882637210201641A747464075FFC64906D355@MX101CL02.corp.emc.com>
Message-ID: <F22BDD77-B1D7-4127-A3F2-3F9E7CFBC803@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peng,

you may confirm any platfrom isn't intersect with linux names for that ?
I not sure. cfs_ prefix introduce a private namespace which may implemented at any way 
I remember that discussion in LUG, but we have a decision to continue discussion about it, but you are stop discussion and make changes without it. I'm strongly about it.
I remember you idea about landing lustre client in kernel tree but that may introduce hard problem with supporting stable code, so we need to discuss and find way - how we will have and support a stable code in opposite to development version in kernel tree.
I strongly against to do it without discussion with all affected persons and companies.


On Dec 14, 2012, at 13:52, Peng, Tao wrote:

> Hi Alex,
> 
> We are not killing the portability code. For now we just wanted to replace it with Linux defined symbols, to a extent that libcfs is unnecessary for Linux client. The libcfs layer remains for platforms that need porting. They just need to define things with Linux names rather than current cfs_ prefix. I admit that some ported code may get broken in during the transition but in theory it is easy to fix them when interests raise on other platforms.
> 
> Cheers,
> Tao
> 
> 
>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf
>> Of Alexey Lyahkov
>> Sent: Friday, December 14, 2012 4:19 PM
>> To: Oleg Drokin
>> Cc: wc-discuss Discussion; lustre-devel at lists.lustre.org Development
>> Subject: Re: [Lustre-devel] [wc-discuss] Important changes to libcfs primitives usage.
>> 
>> Please don't kill a portability code.
>> We have spend many times in past to introduce it's but now you want to kill that work and make
>> portable to systems other then Linux too hard.
>> That is wrong way as supporting a compatibility code have no cost.
>> 
>> On Dec 5, 2012, at 17:54, Oleg Drokin wrote:
>> 
>>> Hello!
>>> 
>>>  I just landed first patch of the series to reduce usage of our libcfs_ wrappers for kernel
>> primitives like libcfs_spin_lock/unlock...
>>>  You can see actual change here: http://review.whamcloud.com/#change,2829
>>> 
>>>  It's highly likely that plenty of patches will be affected. To make our job easier, there is a
>>>  build/libcfs_cleanup.sed script included, you can run it on all your .c and .h files to make
>> necessary replacements:
>>>  sed -i -f build/libcfs_cleanup.sed3  `find . -name "*.h" -or -name "*.c"`
>>> 
>>>  Please be also advised that there are more changes like this are coming (timeline is not very
>> clear ATM, we might be able to wait with the rest until
>>>  after feature freeze) and the sed script will be updated accordingly.
>>> 
>>> Bye,
>>>   Oleg
>>> --
>>> Oleg Drokin
>>> Senior Software Engineer
>>> Whamcloud, Inc.
>>> 
>> 
>> ----------------------------------------------
>> Alexey Lyahkov
>> alexey_lyashkov at xyratex.com
>> 
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 

----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
