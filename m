From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Thu, 20 Dec 2012 14:08:16 +0400
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <6816DF10-6081-40BE-8E73-37DDB9EFADD8@intel.com>
References: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
	<50CF51D4.2090101@tacc.utexas.edu>
	<C4DC6E07-A098-4778-A98B-A3FE9FFCBA87@whamcloud.com>,
	<80C99DE6-76FF-41A8-A565-83541E8AA612@xyratex.com>
	<6816DF10-6081-40BE-8E73-37DDB9EFADD8@intel.com>
Message-ID: <A1C40685-B28B-4029-8A72-7B23F23F0764@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't understand a point to broke something which work now.
as about workaround - did you remember bug with cancel for dirty pages in OFED when Lustre hit a deadlock due bad dirty pages accounting?

On Dec 20, 2012, at 01:36, Dilger, Andreas wrote:

> On 2012-12-19, at 5:27, "Alexey Lyahkov" <alexey_lyashkov@xyratex.com> wrote:
>> Nice idea, what about conflicts with names between linux and freebsd?
>> both have a atomic but with different arguments
>> atomic_set, atomic_add as example.
>> 
>> did you research before make that patch to be sure no conflicts exist?
> 
> Yes, it is possible that such conflicts exist. However, it is impossible to know of such conflicts if there is not any code in the Lustre tree that breaks, and no way to test it.
> 
> I'm aware that you have been working on a FreeBSD FUSE port at times. Have you ever released the patches somewhere? There never was any code in the Lustre tree for it and I've never heard of any users. Virtually (?) all of the Lustre users are on Linux, and making it easier for Linux users to use Lustre is most important.
> 
> I don't want to make it impossible to port to FreeBSD, but if there is a workaround as Xuezhao has proposed, and there are no real users of this code, then the benefits of broader Lustre acceptance outweigh the inconvenience to one or two people developing the FreeBSD FUSE port.
> 
> Cheers, Andreas
> 
>> On Dec 17, 2012, at 22:34, Andreas Dilger wrote:
>> 
>>> On 2012-12-17, at 10:09 AM, John Hammond wrote:
>>>> On 12/05/2012 07:54 AM, Oleg Drokin wrote:
>>>>> I just landed first patch of the series to reduce usage of our libcfs_ wrappers for kernel primitives like libcfs_spin_lock/unlock...
>>>>> You can see actual change here: http://review.whamcloud.com/#change,2829
>>>>> 
>>>>> It's highly likely that plenty of patches will be affected. To make our job easier, there is a
>>>>> build/libcfs_cleanup.sed script included, you can run it on all your .c and .h files to make necessary replacements:
>>>>> sed -i -f build/libcfs_cleanup.sed3  `find . -name "*.h" -or -name "*.c"`
>>>>> 
>>>>> Please be also advised that there are more changes like this are coming (timeline is not very clear ATM, we might be able to wait with the rest until
>>>>> after feature freeze) and the sed script will be updated accordingly.
>>>> 
>>>> I have been wondering about wrappers and typedefs not affected by this change, for example cfs_get_cpu(), cfs_atomic_read() and cfs_proc_dir_entry_t.  In new code and patches should we use the cfs names or their Linux equivalents, get_cpu(), atomic_read(), and struct proc_dir_entry?
>>> 
>>> Ideally, new patches would use the Linux primitives.  However, if they are in client-side code that is compiled for liblustre, then the liblustre builds would fail until the wrappers are renamed to their Linux equivalents (i.e. removing "cfs_" prefix).
>>> 
>>> For server-side code and/or llite it should be fine to use the native Linux functions.
>>> 
>>> Cheers, Andreas
>>> --
>>> Andreas Dilger                       Whamcloud, Inc.
>>> Principal Lustre Engineer            http://www.whamcloud.com/
>>> 
>>> 
>>> 
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

----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
