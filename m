From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 26 Apr 2012 21:54:17 -0600
Subject: [Lustre-devel] [wc-discuss] Re: Lustre and cross-platform
	portability
In-Reply-To: <F19688880B763E40B28B2B462677FBF805EF42BC26@MX09A.corp.emc.com>
References: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
	<5A40CBC5-F91A-4F34-8209-0C216CCE8A5D@dilger.ca>
	<F19688880B763E40B28B2B462677FBF805EF42BC26@MX09A.corp.emc.com>
Message-ID: <1B1F8162-5FC6-4038-810A-EA219EE3BC84@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-04-26, at 20:23, <tao.peng@emc.com> wrote:
> Thank you very much for bringing it up in LUG and getting all these positive support from community.

Tao,
Yes it does look promising. 

>> To revive this thread, based on discussion at the LUG TWG:
>> - there was general consensus that cleaning up the Lustre client
>>  (and server) code was very desirable to do
>> - migrating libcfs to emulate the Linux kernel APIs is also usable.
>>  Ken mentioned that there is relatively little conflict between
>>  the Linux kernel and the MacOS kernel, and the same for WinNT, so
>>  they could use the same function names as Linux without problems.
> I created LU-1346 (http://jira.whamcloud.com/browse/LU-1346) to track libcfs cleanup work.

OK

>> - there was no objection to converting the Lustre code from spaces
>>  to tabs.  My proposal was that build/checkpatch.pl could require
>>  tabs immediately, and new patches should be submitted with tabs
>>  on all new/modified lines (and optionally all lines on small
>>  functions to avoid messy formatting).  This will avoid issues
>>  with current patches in flight, and also avoid "git annotate"
>>  showing the jumbo replace-all-spaces-with-tabs patch for every
>>  line in Lustre, and I think a good fraction of lines will be
>>  updated in the next 9-12 months or more.  As we approach the
>>  actual time for upstream kernel submission is close, then we can
>>  make a final effort to clean up remaining lines in idle code
>>  (which will also be unlikely to conflict with existing work).
> While tabs are the main coding style difference between Lustre and kernel, there are a few minor change that is needed as well. I think we need to do following to match kernel coding style:
> 1. Lustre uses expandtab while kernel requires tabs

Right.

> 2. Lustre has vim syntax rules in most source files, which need to be removed

They should be replaced with explicit vim and enacts syntax rules that have the kernel indent style instead.  If we could get syntax rules that embodied more of the coding style than just indentation, that would be even better. 

> 3. Lustre uses a slightly different comment style, which need to be changed to kernel style

This is DOxygen style formatting.  I had forgotten about this. We had in the past used this inline formatting for producing some documentation, but I'd need to ask about whether there is still a need for this today. In the meantime, please leave the comment style as-is. 


> I created LU-1347 (http://jira.whamcloud.com/browse/LU-1347) to track the coding style changes.
> 
>> There is some hope that the kernel maintainers will not require
>> all of the Lustre macros to be removed, but we can deal with this
>> on a case-by-case basis.
>> 
> IMO, we can divide macros to three groups (or more?):
> 1. Old kernel support macros, kernel maintainers are clear that they won't accept it.

Yes, but we need to maintain this in the external Lustre tree for years after Lustre would be accepted into mainline, since it would not be in vendor kernels (which a majority of Lustre users would be using). 

For such compat macros we need to make an effort to keep the upstream code as close as possible to the external tree, so patches have the most chance of applying. 

> 2. For macros to mark out server code, kernel maintainers can accept it. But I think we need to make sure we don't do it too intrusive.

Sure, and we also need to make sure the ongoing maintenance effort to keep the code working is not too much either.

I'm OK with incremental patches that more cleanly split the client and server code (structures, headers, etc) if that improves the code structure and readability. 

> 3. Lustre feature macros, we can convert them to Kconfig macros.

Sure. Note that some of them may be obsolete, so before you spend too much time cleaning them up, please post a list to Jira. Maybe some of them can be dropped entirely. 

>> On 2012-03-14, at 7:31 PM, Andreas Dilger wrote:
>>> Whamcloud and EMC are jointly investigating how to be able to contribute the Lustre client code into
>> the upstream Linux kernel.
>>> 
>>> As a prerequisite to this, EMC is working to clean up the Lustre client code to better match the
>> kernel coding style, and one of the anticipated major obstacles to upstream kernel submission is the
>> heavy use of code abstraction via libcfs for portability to other operating systems (most notably
>> MacOS and WinNT, but also for liblustre, and potentially *BSD).
>>> 
>>> I have no information that the WinNT project will ever be released by Oracle,
>> 
>> [revised] and the MacOS client needs significant work to update it to the latest version of Lustre,
>> and to get it landed into the Lustre repo,
>> 
>>> so the libcfs portability layer is potentially exacting a high cost in code maintenance and
>> complexity (CLIO being a prime example) for no apparent benefit.  Similarly, the liblustre client
>> needs a portability layer for userspace, and suffers from the same apparent lack of interest or users.
>>> 
>>> I'd like to get some feedback from the Lustre community about removing the libcfs abstraction
>> entirely, or possibly restructuring it to look like the Linux kernel API, and having the other
>> platforms code against it as a Linux portability layer, like ZFS on Linux uses the Solaris Portability
>> Layer (SPL) to avoid changing the core ZFS code.  A related topic is whether it would be better to
>> replace all cfs_* functions with standard Linux kernel functions en-masse, or migrate away from cfs_*
>> functions slowly?
>>> 
>>> Also, we're planning on deprecating the liblustre client code, due to lack of interest/usage.  The
>> current code is in disrepair, and we've been keeping it around for years without any benefit, and
>> while I was one of the strongest advocates for keeping it in our back pocket in case of future needs,
>> I don't see that materializing in the future.
>>> 
>>> The liblustre code would be left in the tree for now, in case someone from the community is
>> interested to get it working and maintain it, and it may be updated on a best effort basis.  If nobody
>> steps forward to do this work, the liblustre code would be deleted from the development branch in a
>> year or so.
>>> 
>>> 
>>> Unfortunately, after starting this thread, I may not be able to reply to questions in a timely
>> manner due to vacation.  I look forward to a thread that concludes with unanimous agreement from all
>> parties. :-)
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
>> 
>> Cheers, Andreas
>> 
>> 
>> 
>> 
>> 
> 
