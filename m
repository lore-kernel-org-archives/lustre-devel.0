From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Jun 2018 08:29:28 +1000
Subject: [lustre-devel] [PATCH v2 01/25] staging: lustre: libcfs:
 restore UMP handling
In-Reply-To: <alpine.LFD.2.21.1806132248500.12664@casper.infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
 <87muwiuiuz.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806132248500.12664@casper.infradead.org>
Message-ID: <87h8m6ialz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Doug Oucharek <dougso@me.com>, Amir Shehata <amir.shehata@intel.com>

On Wed, Jun 13 2018, James Simmons wrote:

>> > With the cleanup of the libcfs SMP handling all UMP handling
>> > was removed. In the process now various NULL pointers and
>> > empty fields are return in the UMP case which causes lustre
>> > to crash hard. Restore the proper UMP handling so Lustre can
>> > properly function.
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

I'm not convinced there will be lots of NULL pointer checks - maybe one
or two.  Most the accesses to the structure are inside helper
functions which are empty inlines in the UP build.

However I don't object to a static cfs_cpt_tab if that turns out to make
some code simpler.   I would want it to be clear up-front which code was
simplified so that an informed decision could be made.

Thanks,
NeilBrown


>  
>> I really think this is a step backwards.  If you can identify specific
>> problems caused by the current code, I'm sure we can fix them.
>> 
>> >
>> > Signed-off-by: James Simmons <uja.ornl@yahoo.com>
>> > Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
>> 
>> This bug doesn't seem to mention this patch at all
>> 
>> > Reviewed-on: http://review.whamcloud.com/18916
>> 
>> Nor does this review.
>
> Yeah its mutated so much from what is in the Intel tree.
> I do believe it was the last patch to touch this.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180614/0fb53af7/attachment.sig>
