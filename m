From: NeilBrown <neilb@suse.com>
Date: Thu, 26 Oct 2017 08:55:06 +1100
Subject: [lustre-devel] [PATCH 0/9] Assorted cleanups for
 staging/.../lustre/ldlm/ldlm_flock.c
In-Reply-To: <alpine.LFD.2.20.1710242320020.20646@casper.infradead.org>
References: <150871988297.3340.4522589460981284121.stgit@noble>
 <alpine.LFD.2.20.1710242320020.20646@casper.infradead.org>
Message-ID: <874lqmevut.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

On Tue, Oct 24 2017, James Simmons wrote:

>> This file contains quite a bit of dead code and unused variables.
>> This patch series cleans it up in various ways.
>> It should change behaviour at all, just code
>> readability/maintainabilty.
>> 
>> I sent the back in July but got not response, possibly because there
>> were included with other patches which caused a distraction.
>> So here they are by themselves.
>
> Thanks for separating them out. I will give them a spin.
>

Thanks.  I have a growing series of cleanups (43 at present, including
these and the namei/dcache patches).  Is posting them here the best
approach?  I assume I should keep them in well-defined groups.  Should I
wait for one set to be merged before sending more, or should I just send
them when I think they are ready and you (or others) will look at them
as time permits.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171026/38e34cca/attachment.sig>
