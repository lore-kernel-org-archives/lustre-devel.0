From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 10:25:48 +1100
Subject: [lustre-devel] [PATCH 0/7] lustre: move DocBook comments to
 sphinix format
In-Reply-To: <alpine.LFD.2.21.1903021928001.29568@casper.infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
 <alpine.LFD.2.21.1903021928001.29568@casper.infradead.org>
Message-ID: <87o96rsfpf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Mar 02 2019, James Simmons wrote:

>> The Linux kernel deprecated DocBook so update Lustre to using
>> sphinix instead. I'm no Sphinix expert so things might be missed
>> but the major has been ported over. This should get the lustre
>> in shape to move out of staging.
>
> Forgot to add. This is against lustre-testing since the wip* trees
> are stil churning.
>  

Definitely the right thing to do.  wip is just patches that need more
work.  It never makes sense to build on them.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190304/2cacfff0/attachment.sig>
