From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 10:36:12 +1000
Subject: [lustre-devel] [PATCH 01/18] lustre: grant: add support for
 OBD_CONNECT_GRANT_PARAM
In-Reply-To: <alpine.LFD.2.21.1807061528170.15728@casper.infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-2-git-send-email-jsimmons@infradead.org>
 <0F41C25D-E055-489A-82B6-CF4728AFF905@cray.com>
 <alpine.LFD.2.21.1807061528170.15728@casper.infradead.org>
Message-ID: <87bmayrdoj.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jul 06 2018, James Simmons wrote:

>> ?On 7/2/18, 6:25 PM, "lustre-devel on behalf of James Simmons" <lustre-devel-bounces at lists.lustre.org on behalf of jsimmons@infradead.org> wrote:
>> 
>>     From: Johann Lombardi <jlombardi@whamcloud.com>
>>     Signed-off-by: Johann Lombardi <jlombardi@whamcloud.com>
>>     Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
>>     WC-bug-id: https://jira.whamcloud.com/browse/2049
>>     Reviewed-on: http://review.whamcloud.com/7793
>>     Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>>     Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
>>  
>> James, can you fix this up?  I'm not sure how historical patches should be attributed, but Johann's address seems
>> wrong.
>> 
>> From should be attributed to Johann Lombardi <johann.lombardi@intel.com> .  Also, the Bug URL should be
>> https://jira.whamcloud.com/browse/LU-2049 .
>
> This is tricky one. The reason I updated the email address to avoid 
> bouncing emails.

I would recommend never trying to update email addresses.  The kernel
history is full of addresses that are no longer valid.
Discussion of patches should happen on lists, and interested parties
should subscribe to the lists.  If someone wants to particularly see
emails sent to some old address of their's it should be easy enough to
add some filtering.  If you particularly want to contact the author of
some old patch, it is unlikely to take to much searching to find a valid
address (just ask on the email list - someone is bound to know).

Bounces are a little bit annoying, but so is spam - we just learn ways
to deal with it.

For this particular patch I've restored the addresses from the original
patch, even though I know some of them are no longer valid.  They were
valid when the review was done, and the effectively give credit to the
company which paid for the review.  I won't bother the rest though.

Thanks,
NeilBrown


> Also this allows the original author the chance to
> still reply. Does that seem reasonable? It is still in the air for
> some people what their email address is to me. Ah you are right I
> dropped the s. Its should be https://jira.whamcloud.com/....
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180723/2d64cee1/attachment.sig>
