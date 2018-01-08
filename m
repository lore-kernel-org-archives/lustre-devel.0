From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 08:39:17 +1100
Subject: [lustre-devel] [PATCH 03/15] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <20180108145157.GA32570@kroah.com>
References: <151355781721.6200.2136335532722530242.stgit@noble>
 <151355799030.6200.8100283223734974485.stgit@noble>
 <20180108145157.GA32570@kroah.com>
Message-ID: <87y3l8av3u.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Mon, Jan 08 2018, Greg Kroah-Hartman wrote:

> On Mon, Dec 18, 2017 at 11:46:30AM +1100, NeilBrown wrote:
>> All usages of the form
>>   LIBCFS_ALLOC(variable, sizeof(variable))
>> or
>>   LIBCFS_ALLOC(variable, sizeof(variable's-type))
>> 
>> are changed to
>>   variable = kzalloc(sizeof(...), GFP_NOFS);
>> 
>> Similarly, all
>>    LIBCFS_FREE(variable, sizeof(variable))
>> become
>>    kfree(variable);
>> 
>> None of these need the vmalloc option, or any of the other minor
>> benefits of LIBCFS_ALLOC().
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> As this broke the kbuild system, I'll stop here in this patch series.
> Can you please fix it up, rebase and resend the remaining ones in this
> series?

Hi Greg,
 thanks for applying the patches.

 That patch had a typo in code that was only included if CONFIG_INFINIBAND is
 enabled, which I didn't have in my testing at the time.  I hadn't
 resent when I fixed it as I was waiting to see if there would be
 feedback.
 If the protocol is "you apply sometime after two weeks if there is no
 feedback (and no breakage)", then I'll aim to work with that.

 I'll resend with the rest of the kmalloc patches.

Thanks,
NeilBrown


 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180109/ab498f88/attachment.sig>
