From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Jun 2018 12:49:07 +1000
Subject: [lustre-devel] [PATCH v3 19/26] staging: lustre: libcfs: report
 NUMA node instead of just node
In-Reply-To: <alpine.LFD.2.21.1806260146520.31196@casper.infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-20-git-send-email-jsimmons@infradead.org>
 <87y3f38ye6.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806260146520.31196@casper.infradead.org>
Message-ID: <87in656j18.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 26 2018, James Simmons wrote:

>> On Sun, Jun 24 2018, James Simmons wrote:
>> 
>> > From: Dmitry Eremin <dmitry.eremin@intel.com>
>> >
>> > Reporting "HW nodes" is too generic. It really is reporting
>> > "HW NUMA nodes". Update the debug message.
>> 
>> I'm not happy with this patch description.....
>
> How about:
>
> In the HPC world a node refers to the actual whole computer system
> used in a cluster. Reporting just "HW nodes" is not clear so change
> the debug report to "HW NUMA nodes" since this report the number
> of NUMA nodes in use by Lustre.
>

That's not actually the part I was complaining about.
It was the fact that there were multiple parts of the patch that weren't
mentioned at all.

But I like your revision anyway, so I've updated the patch.
Thanks!

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180627/05d1e08e/attachment.sig>
