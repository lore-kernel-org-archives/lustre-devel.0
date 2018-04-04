From: NeilBrown <neilb@suse.com>
Date: Thu, 05 Apr 2018 08:00:14 +1000
Subject: [lustre-devel] [PATCH 11/17] staging: lustre: libcfs: discard
 cfs_time_shift().
In-Reply-To: <CB90FEDF-3F67-46A7-8EC3-ABC788E7978C@intel.com>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760863.27689.4681198496926109808.stgit@noble>
 <alpine.LFD.2.21.1803302001440.9681@casper.infradead.org>
 <0B6A147C-7E98-4B00-AF32-AF8843484CF9@intel.com>
 <87muyl1bzs.fsf@notabene.neil.brown.name>
 <CB90FEDF-3F67-46A7-8EC3-ABC788E7978C@intel.com>
Message-ID: <87tvsqy6mp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Apr 04 2018, Dilger, Andreas wrote:

> On Apr 2, 2018, at 16:26, NeilBrown <neilb@suse.com> wrote:
>> On Mon, Apr 02 2018, Dilger, Andreas wrote:
>>> On Mar 30, 2018, at 13:02, James Simmons <jsimmons@infradead.org> wrote:
>>>>> This function simply multiplies by HZ and adds jiffies.
>>>>> This is simple enough to be opencoded, and doing so
>>>>> makes the code easier to read.
>>>>> 
>>>>> Same for cfs_time_shift_64()
>>>> 
>>>> Reviewed-by: James Simmons <jsimmons@infradead.org>
>>> 
>>> Hmm, I thought we were trying to get rid of direct HZ usage in modules,
>>> because of tickless systems, and move to e.g. msecs_to_jiffies() or similar?
>> 
>> Are we?  I hadn't heard but I could easily have missed it.
>> Documentation/scheduler/completion.txt does say
>> 
>>    Timeouts are preferably calculated with
>>    msecs_to_jiffies() or usecs_to_jiffies().
>> 
>> but is isn't clear what they are preferred to.  Do you remember where
>> you heard? or have a reference?
>
> I thought the goal was to avoid hard-coding the HZ value so that kernels
> could have variable clock rates in the future.

It is hard to imagine it ever being possible to change, at runtime, the
length of time represented by one jiffie.
Durations, measured in jiffies, are stored it lots of different places,
and they would all need to be changed to msecs - very error prone work.
I think it would be much more likely to set HZ to some large value, and
have the clock tick at varying multiples of that.  The NOHZ work already
does something a bit like that I think.

Thanks,
NeilBrown

>
> Cheers, Andreas
>
>> $ git grep ' \* *HZ'  |wc
>>   2244   15679  170016
>> $ git grep msecs_to_jiffies | wc
>>   3301   13151  276725
>> 
>> so msecs_to_jiffies is slightly more popular than "* HZ" (even if you add
>> in "HZ *").  But that could just be a preference for using milliseconds
>> over using seconds.
>> 
>> $ git grep msecs_to_jiffies   | grep -c '[0-9]000'
>> 587
>> 
>> so there are only 587 places that msecs_to_jiffies is clearly used in
>> place of multiplying by HZ.
>> 
>> If we were to pursue this, I would want to add secs_to_jiffies() to
>> include/linux/jiffies.h and use that.
>> 
>> Thanks,
>> NeilBrown
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180405/68260140/attachment.sig>
