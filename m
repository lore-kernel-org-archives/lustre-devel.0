From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Jun 2018 14:19:43 +1000
Subject: [lustre-devel] [PATCH 09/24] lustre: don't use spare bits in
 iattr.ia_valid
In-Reply-To: <alpine.LFD.2.21.1806210233170.3886@casper.infradead.org>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669036.10587.17899565981649604892.stgit@noble>
 <alpine.LFD.2.21.1806210233170.3886@casper.infradead.org>
Message-ID: <87fu1gdb4w.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 21 2018, James Simmons wrote:

>> Using spare bits in iattr.ia_valid is not safe as the
>> bits might get used for some other purpose without
>> us noticing.
>> lustre currently used 4 spare bit, but they are all
>> defined in different places so this isn't immediately
>> obvious.
>> 
>> This patch brings all those bit definitions together
>> and defined a new op_data field (op_xvalid) to hold
>> the extra validity bits.
>> 
>> It also replaces sa_valid in struct cl_setattr_io
>> with sa_avalid and sa_xvalid.  Changing the name is
>> helpful as sa_valid already has another use within
>> lustre.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Nak: I see regressions with this patch.
>
> [12368.453655] Lustre: DEBUG MARKER: == sanity test 240: race between ldlm 
> enqueue and the connection RPC (no ASSERT) ===================== 21:
> 16:30 (1529543790)
> [12368.760832] BUG: Dentry 
> 000000002646a847{i=200004282000008,n=f237.sanity}  still in use (1) 
> [unmount of lustre lustre]
> [12368.773746] WARNING: CPU: 1 PID: 10861 at fs/dcache.c:1514 
...
> [12369.385564] Lustre: Unmounted lustre-client
> [12369.393247] VFS: Busy inodes after unmount of lustre. Self-destruct in 
> 5 seconds.  Have a nice day...
>
> When I remove this patch things go back to normal. This will not show up
> if you do a ONLY="240" sh ./sanity.sh. You have to run the sanity.sh in
> total to make this show up.
>

(clearly I read my email in the wrong order)
Very odd.  This suggests some sort of life-time-management problem
with inodes, but the changes shouldn't affect that at all.
I've gone back over the patch closely and cannot see anything wrong - it
is really very simple: it just moves flag bits around.

I haven't got as far as 240 yet as changes to kvmalloc have caused
earlier problem (my VMs don't have much RAM). I'll see if I can
coax it all the way to 240 and see what happens.

Thanks for the report.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180621/0a7c0f77/attachment.sig>
