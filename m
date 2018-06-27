From: NeilBrown <neilb@suse.com>
Date: Wed, 27 Jun 2018 12:50:54 +1000
Subject: [lustre-devel] [PATCH v3 08/26] staging: lustre: libcfs: add
 cpu distance handling
In-Reply-To: <alpine.LFD.2.21.1806260213340.31196@casper.infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-9-git-send-email-jsimmons@infradead.org>
 <874lhradxj.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806260213340.31196@casper.infradead.org>
Message-ID: <87fu196iy9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 26 2018, James Simmons wrote:

>> On Sun, Jun 24 2018, James Simmons wrote:
>> 
>> > From: Amir Shehata <amir.shehata@intel.com>
>> >
>> > Add functionality to calculate the distance between two CPTs.
>> > Expose those distance in debugfs so people deploying a setup
>> > can debug what is being created for CPTs.
>> 
>> This patch doesn't expose anything in debugfs - a later patch
>> does that.
>> So I've changed the comment to "Prepare to expose those ...."
>
> Doug Oucharek recommonds the following commit message body:
>
> Add cpu distance routines which will be used by the Multi-Rail feature 
> to determine what fabric interface is nearest to the core we are currently 
> running on. Configuration of these distances will be provided from user 
> space via configuration routines in Lustre.

Thanks - I like this more.  Updated.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180627/cc1c67b7/attachment.sig>
