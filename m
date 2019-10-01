From: NeilBrown <neilb@suse.de>
Date: Wed, 02 Oct 2019 09:19:38 +1000
Subject: [lustre-devel] [PATCH 069/151] lustre: ptlrpc: use lu_extent in
 layout_intent
In-Reply-To: <alpine.LFD.2.21.1910011852440.9239@casper.infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <1569869810-23848-70-git-send-email-jsimmons@infradead.org>
 <87o8z16t95.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1910011852440.9239@casper.infradead.org>
Message-ID: <87a7ak6ol1.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Oct 01 2019, James Simmons wrote:

>> > From: Jinshan Xiong <jinshan.xiong@gmail.com>
>> >
>> > This way it will be easier to check and print the extent
>> > of layout.
>> >
>> > WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
>> > Lustre-commit: c1f450270dda ("LU-9971 ptlrpc: use lu_extent in layout_intent")
>> > Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
>> > Reviewed-on: https://review.whamcloud.com/29087
>> > Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
>> > Reviewed-by: Bobi Jam <bobijam@hotmail.com>
>> > Signed-off-by: James Simmons <jsimmons@infradead.org>
>> > ---
>> >  include/uapi/linux/lustre/lustre_idl.h  | 3 +--
>> >  include/uapi/linux/lustre/lustre_user.h | 2 +-
>> >  2 files changed, 2 insertions(+), 3 deletions(-)
>> 
>> 
>> hi James,
>>  most of this patch is missing - it seems to have been merged into the
>>  next patch by mistake.
>>  I'm walking through patches checking that code still compiles after
>>  each patch, and this one doesn't.
>> 
>> NeilBrown
>
> Ugh. My tree is on a NFS partition so some times when I apply a patch 
> while on one node the entire change doesn't show up on another node.
> Do you need me to resend the patch?

No thanks - I've fixed it up in my tree.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191002/78e3fd46/attachment.sig>
