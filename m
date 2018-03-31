From: NeilBrown <neilb@suse.com>
Date: Sat, 31 Mar 2018 16:47:00 +1100
Subject: [lustre-devel] Current results and status of my upstream work
In-Reply-To: <alpine.LFD.2.21.1803301844001.9681@casper.infradead.org>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87bmgvrsj8.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1802120233260.3291@casper.infradead.org>
 <871sg65bid.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1803301844001.9681@casper.infradead.org>
Message-ID: <874lkw3igb.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Mar 30 2018, James Simmons wrote:

>
> To let you know test 154 always triggers a LBUG due to splice changes that
> landed. I'm seeing
>
> 2018-03-30 13:41:37 [ 6351.749923] BUG: unable to handle kernel paging 
> request at ffffffffffffffbc
> 2018-03-30 13:41:37 [ 6351.757031] IP: ll_splice_alias+0x1df/0x250 
> [lustre]

Can you run
  ./scripts/faddr2line drivers/staging/lustre/lustre/llite/namei.o  ll_splice_alias+0x1df/0x250 

(you might need a different pathname for namei.o, depending on how you
build the kernel).

d_splice_alias() can return an error (very rarely I think) and the
CDEBUG() at the end of ll_splice_alias wouldn't be happy about that.

The code shows a crash at:
  2b:*	48 8b 48 30          	mov    0x30(%rax),%rcx		<-- trapping instruction

and 
   RAX: ffffffffffffff8c

which is -116 or -ESTALE.
That is an error which d_splice_alias() can get from __d_unalias, so
I guess that is what is happening.

I'll dig through d_splice_alias() and try to work out what that means.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180331/510a5e99/attachment.sig>
