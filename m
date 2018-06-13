From: Doug Oucharek <doucharek@cray.com>
Date: Wed, 13 Jun 2018 22:18:03 +0000
Subject: [lustre-devel] [PATCH v2 01/25] staging: lustre: libcfs:
 restore UMP handling
In-Reply-To: <alpine.LFD.2.21.1806132248500.12664@casper.infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
 <87muwiuiuz.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806132248500.12664@casper.infradead.org>
Message-ID: <17F46A71-4A75-499D-9220-A8503C6C26F3@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Jun 13, 2018, at 3:02 PM, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>>> With the cleanup of the libcfs SMP handling all UMP handling
>>> was removed. In the process now various NULL pointers and
>>> empty fields are return in the UMP case which causes lustre
>>> to crash hard. Restore the proper UMP handling so Lustre can
>>> properly function.
>> 
>> Can't we just get lustre to handle the NULL pointer?
>> Is most cases, the pointer is accessed through an accessor function, and
>> on !CONFIG_SMP, that can be a static inline that doesn't even look at
>> the pointer.
> 
> Lots of NULL pointer checks for a structure allocated at libcfs module 
> start and only cleaned up at libcfs removal is not a clean approach.
> So I have thought about it and I have to ask why allocate a global
> struct cfs_cpu_table. It could be made static and fill it in which would
> avoid the whole NULL pointer issue. Plus for the UMP case why allocate
> a new cfs_cpu_table with cfs_cpt_table_alloc() which is exactly like
> the default UMP cfs_cpu_table. Instead we could just return the pointer
> to the static default cfs_cpt_tab every time. We still have the NULL
> ctb_cpumask field to deal with. Does that sound like a better solution
> to you? Doug what do you think?

I like your suggestion, James.  Always having a cfs_cpu_table so we don?t have to worry about a NULL pointer would be good.  I think we can track down the code which relies on the cpumask field to make it safe for the NULL case.  Is there possibility of having an empty cpumask rather than it being NULL?

> 
>> I really think this is a step backwards.  If you can identify specific
>> problems caused by the current code, I'm sure we can fix them.
>> 
>>> 
>>> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
>>> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
>> 
>> This bug doesn't seem to mention this patch at all
>> 
>>> Reviewed-on: http://review.whamcloud.com/18916
>> 
>> Nor does this review.
> 
> Yeah its mutated so much from what is in the Intel tree.
> I do believe it was the last patch to touch this.
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
