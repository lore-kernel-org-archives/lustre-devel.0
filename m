From: Fan Yong <yong.fan@whamcloud.com>
Date: Sat, 04 Feb 2012 00:17:39 +0800
Subject: [Lustre-devel] Lustre dcache clean up and distributed locking
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E803AF01@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805E7E684CD@MX09A.corp.emc.com>
	<AC57B2B9-5559-4713-905D-7AC9BAE3B1DB@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E7E6857F@MX09A.corp.emc.com>
	<8449503C-66B3-4CDC-89BF-5B52E6D29579@whamcloud.com>
	<5F3A45681A0F5944B3194CF8C8FB905B66FA4DD4F9@MX17A.corp.emc.com>
	<4F19A01B.4070405@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E7E68AA7@MX09A.corp.emc.com>
	<AEB2D859-5F0D-4D32-9719-DDD993D6921A@whamcloud.com>
	<4F27D846.6010504@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E803AF01@MX09A.corp.emc.com>
Message-ID: <4F2C08A3.4060206@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2/3/12 3:37 PM, tao.peng at emc.com wrote:
>> -----Original Message-----
>> From: Fan Yong [mailto:yong.fan at whamcloud.com]
>> Sent: Tuesday, January 31, 2012 8:02 PM
>> To: Peng, Tao
>> Cc: Andreas Dilger; bergwolf at gmail.com; Tang, Haiying; faibish, sorin; Liu, Xuezhao;
>> laisiyao at whamcloud.com; green at whamcloud.com; eeb at whamcloud.com; bryon at whamcloud.com; lustre-
>> devel at lists.lustre.org
>> Subject: Re: Lustre dcache clean up and distributed locking
>>
>> On 1/31/12 7:27 AM, Andreas Dilger wrote:
>>> On 2012-01-30, at 12:46 AM,<tao.peng@emc.com>   wrote:
>>>> Sorry for the late reply. I got your email earlier but didn't have chance to read the document due
>> to very limited internet access.
>>>> Thank you very much for taking detailed look at the document and giving so many valuable comments.
>>>>
>>>> About adding new inode bitlock, I must admit that I missed hardlink case. Although the lock mode
>> can be changed to be the same as LOOKUP lock, I agree that inode bitlock cannot sufficiently protect
>> every name/dentry separately for hardlinked files. And I agree, as you suggested in the document,
>> adding a name entry based lock can solve it.
>>>> IIUC, to add a name entry based lock, both client and server should be modified, and LDLM need to
>> be changed to manage the new lock information. Like new inode bitlock, the name entry based lock will
>> as well introduce interoperability issues as a result of on wire protocol change. And in DNE
>> environment as Andreas explained, the original plan is to get LOOKUP on both master MDT and remote MDT.
>> If we introduce name entry based lock, DNE case may need some change as well.
>>>> I will take a closer look at the approach. In the meanwhile, could you please confirm if it is the
>> right way to go? The benefit of above complexity seems to be better distributed dentry locking under
>> dcache framework.
>>>> What do others think? Andreas?
>>> Tao, before we go down the road of implementing such a change, there would have to be clear benefits
>> to the performance and/or kernel integration before we could accept the interoperability issues and
>> added code complexity.
>>> The benefits of having a per-name lock, as I see them, are:
>>> - can be cancelled separately from other name locks
>>> - can be changed independently from the inode permissions (LOOKUP)
>>> - potential ease of integration with the Linux dcache
>>>
>>> The drawbacks of introducing a per-name lock:
>>> - only useful for hard-linked files (uncommon case)
>>> - added code complexity for a new lock type
>>> - incompatibility with existing client/server
>>> - additional code to handle incompatibility transparently
>>> - lock enqueue may need extra RPC for each name lock (different resource)
>>> - lock cancellation may need an extra RPC for each resource
>>>
>>> The way I see it is that the DENTRY lock would need to be a different resource for each name on a
>> file.  The only way this is going to be useful AFAICS is if the client enqueues each DENTRY lock on a
>> separate resource, so that it can be granted and cancelled independently of the LOOKUP lock (which is
>> on the FID and would be common for all names that reference this inode).  That would either need an
>> extra RPC for every filename lookup (to enqueue both the DENTRY and LOOKUP locks) or a new
>> LDLM_ENQUEUE RPC that can request and be granted two different locks (FID [seq, oid, ver, 0], and
>> FID+name hash [seq, oid, ver, hash]) in a single RPC.
>>> So, the main question is how much better the client dcache/VFS integration will be with the DCACHE
>> lock compared to the existing mechanism with the LOOKUP (FID) lock?  Is it impossible (or very
>> difficult) to use the existing mechanism for the new lockless dcache code?  Or is it a matter of this
>> being a somewhat cleaner implementation, but not critical for moving forward?
>>> I'm aware that our dcache code has been too complex for some time, but I haven't looked recently to
>> see how much of this is due to using/supporting old kernel APIs, and how much of it is due to the use
>> of the LOOKUP lock on the FID protecting too much of the state on the client.
>>> Cheers, Andreas
>> Hi Tao,
>>
>> To introduce either per-name lock or DENTRY lock is mainly for removing
>> Lustre special flag "DCACHE_LUSTRE_INVALID" to simply Lustre code. But
>> if such simplification causes more complex ldlm logic, we have to
>> consider whether it is worth to remove "DCACHE_LUSTRE_INVALID". It is
>> not impossible to make "DCACHE_LUSTRE_INVALID" accepted by linux kernel.
>> On the other hand, "DCACHE_LUSTRE_INVALID" can work together with
>> lockless dcache in new linux kernel also.
>>
>> So to push the project move forward, we can divide it as two parts
>> (according to your document): Lustre dcache code cleanup, and some new
>> ldlm logic to remove "DCACHE_LUSTRE_INVALID". Before we reach an
>> agreement on the second part, we can start from the first part to
>> cleanup Lustre dcache code. How do you think?
>>
> Thank you, Andreas and Yong. I tend to agree with you that we should avoid the complexity if there is no obvious benefits. However, as we need to make sure the code is acceptable by kernel community, I will try to consolidate a design for adding the new type of lock but just don't implement it at this point. And if later we are asked (by kernel community developers) to do it, we just need to do the implementation.

Hi Tao,

We has another way to remove Lustre special dentry flags 
"DCACHE_LUSTRE_INVALID". To indicate the dentry in dcache without LOOKUP 
lock protected but not unhashed yet, we can add new flags in 
"ll_dentry_data" (pointed by "dentry::d_fsdata"). Since it is Lustre 
private date, no need to worry about whether the new flags will conflict 
with any other VFS standard "dentry::d_flags" or not, and maybe save 
some effort to implement the complex DENTRY lock in your original design.

Cheers,
Nasf

> Please stay tuned.
>
> Best,
> Tao
>
>> Cheers,
>> --
>> Nasf
>>
>>>
>>>>> -----Original Message-----
>>>>> From: Fan Yong [mailto:yong.fan at whamcloud.com]
>>>>> Sent: Saturday, January 21, 2012 1:11 AM
>>>>> To: Peng, Tao; bergwolf at gmail.com
>>>>> Cc: Tang, Haiying; adilger at whamcloud.com; faibish, sorin; Liu, Xuezhao; laisiyao at whamcloud.com;
>>>>> green at whamcloud.com; eeb at whamcloud.com; Bryon Neitzel
>>>>> Subject: Re: Lustre dcache clean up and distributed locking
>>>>>
>>>>> Hi Tao,
>>>>>
>>>>> Excellent work. I just added some comments inside your document. Please check.
>>>>>
>>>>>
>>>>> Best Regards,
>>>>> Fan Yong
>>>>> Whamcloud, Inc.
>>>>>
>>>>> On 1/20/12 9:34 AM, haiying.tang at emc.com wrote:
>>>>>> Hi Andreas,
>>>>>>
>>>>>> Tao is on vacation now. It might be difficult for him to check emails due to limited internet
>> access
>>>>> at hometown.
>>>>>> For urgent issue, you folks could send email to his gmail account bergwolf at gmail.com.
>>>>>>
>>>>>> Thanks,
>>>>>> Haiying
>>>>>>
>>>>>> -----Original Message-----
>>>>>> From: Andreas Dilger [mailto:adilger at whamcloud.com]
>>>>>> Sent: 2012?1?20? 1:39
>>>>>> To: Peng, Tao
>>>>>> Cc: faibish, sorin; Tang, Haiying; Liu, Xuezhao;
>>>>>> laisiyao at whamcloud.com; yong.fan at whamcloud.com; green at whamcloud.com;
>>>>>> eeb at whamcloud.com
>>>>>> Subject: Re: Lustre dcache clean up and distributed locking
>>>>>>
>>>>>> On 2012-01-17, at 3:21 AM,<tao.peng@emc.com>   <tao.peng@emc.com>   wrote:
>>>>>>> Thanks Siyao and Oleg for answering my dcache revalidation question on lustre mailing list. I
>>>>> updated the design to reflect it.
>>>>>>> Please see attachment.
>>>>>> Tao,
>>>>>> Fan Yong is also taking a more detailed look at your document and will
>>>>>> hopefully have a chance to reply before the New Year holidays.
>>>>>>
>>>>>> Also, we are just working on landing the patches to add support for
>>>>>> Linux
>>>>>> 2.6.38 for the Lustre client.  One of the patches relates to the
>>>>>> lockless dcache changes that were introduced in that kernel.  If you
>>>>>> are interested to review this patch, and become more familiar with the
>>>>>> Lustre development process, you should visit http://review.whamcloud.com/1865 for the patch.
>>>>>>
>>>>>> You need to create an account in Gerrit using OpenID (Google, mostly),
>>>>>> and an account in our bug tracking system (http://jira.whamcloud.com)
>>>>>> if you haven't already.
>>>>>>
>>>>>>>> -----Original Message-----
>>>>>>>> From: Andreas Dilger [mailto:adilger at whamcloud.com]
>>>>>>>> Sent: Tuesday, January 17, 2012 4:16 PM
>>>>>>>> To: Peng, Tao
>>>>>>>> Cc: faibish, sorin; Tang, Haiying; Liu, Xuezhao; Lai Siyao; Fan
>>>>>>>> Yong; Oleg Drokin; Eric Barton
>>>>>>>> Subject: Re: Lustre dcache clean up and distributed locking
>>>>>>>>
>>>>>>>> On 2012-01-16, at 9:25 PM,<tao.peng@emc.com>   wrote:
>>>>>>>>> I finally started to work on Lustre dcache cleanup and locking.
>>>>>>>>> After reading Lustre, ocfs2 and VFS
>>>>>>>> dcache related code, I came to a design for cleaning up Lustre
>>>>>>>> dcache code and doing distributed locking under dcache. For
>>>>>>>> distributed locking, the main idea is to add a new inode bitlock
>>>>>>>> DENTRY lock to just protect valid dentry, instead of letting LOOKUP
>>>>>>>> lock handle multiple purpose, which makes client unable to know
>>>>>>>> whether file is deleted or not when server cancels LOOKUP lock. Instead, client holds PR mode
>>>>> DENTRY lock on all valid denties and when server cancels it, client knows the file is deleted.
>>>>>>>>> For details, please see the attachments (I attached both word and
>>>>>>>>> pdf versions as I am not sure if
>>>>>>>> which is more convenient for you:). And please help to review and comment. Thank you!
>>>>>>>>
>>>>>>>> Hi Tao,
>>>>>>>> I'm passing this on to the engineers that are most familiar with the
>>>>>>>> DLM and client dcache code in Lustre.  After a quick first read
>>>>>>>> through your document, your investigation of the client code is very
>>>>>>>> insightful and looks like it will be able to remove some of the significant complexity that has
>>>>> grown over time in the llite code.
>>>>>>>> Cheers, Andreas
>>>>>>>> --
>>>>>>>> Andreas Dilger                       Whamcloud, Inc.
>>>>>>>> Principal Engineer                   http://www.whamcloud.com/
>>>>>>>>
>>>>>>>>
>>>>>>> <dcache_distributed_locking-v2.docx>
>>>>>> Cheers, Andreas
>>>>>> --
>>>>>> Andreas Dilger                       Whamcloud, Inc.
>>>>>> Principal Engineer                   http://www.whamcloud.com/
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>> Cheers, Andreas
>>> --
>>> Andreas Dilger                       Whamcloud, Inc.
>>> Principal Engineer                   http://www.whamcloud.com/
>>>
>>>
>>>
>>>
