From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Jan 2018 09:02:06 +1100
Subject: [lustre-devel] [bug report] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <20180123092859.ghhehynmuxstdijv@mwanda>
References: <20180115092657.om2gdrcwlajo2tvi@mwanda>
 <87r2qh83np.fsf@notabene.neil.brown.name>
 <D6E57F1D-7686-43A5-A8E2-ED9CC29B3D0F@intel.com>
 <4EDC2CF6-F999-4B09-B7CE-71281845F6F6@intel.com>
 <20180123092859.ghhehynmuxstdijv@mwanda>
Message-ID: <87a7x48c9t.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 23 2018, Dan Carpenter wrote:

> On Tue, Jan 23, 2018 at 09:25:41AM +0000, Zhen, Liang wrote:
>> Hi, I just realized the ?free_conn? parameter is unused in kernel source, but it?s actually used in the original patch: https://review.whamcloud.com/#/c/17892  , so I think it should be fixed in the kernel.
>> 
>
> Dmitry already sent a patch for this.

Thanks - I hadn't seen that.
Though it seems Greg isn't too happy with the patch yet... unless I
failed to find the update too.

Hopefully it will get sorted soon.

And thanks for finding this bug - it validates the work of converting to
more standard interfaces :-)

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180124/bfe1d8ec/attachment.sig>
