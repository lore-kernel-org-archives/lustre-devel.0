From: NeilBrown <neilb@suse.com>
Date: Fri, 22 Jun 2018 13:19:07 +1000
Subject: [lustre-devel] [PATCH 21/24] lustre: move remainder of
 linux-tracefile.c to tracefile.c
In-Reply-To: <alpine.LFD.2.21.1806210236200.3886@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669084.10587.6920959206498193596.stgit@noble>
 <alpine.LFD.2.21.1806210236200.3886@casper.infradead.org>
Message-ID: <87y3f7bj9w.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 21 2018, James Simmons wrote:

>> It's good to keep related code together.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Nak. For some reason this corrupts my dmesg output. Its really strange and
> I haven't figured it out yet.

This patch cannot possibly be the cause of any such behavioural change.
It purely moves code from one file to another, it doesn't change the
code at all.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180622/aaa02fe3/attachment.sig>
