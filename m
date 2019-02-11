From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 11:58:55 +1100
Subject: [lustre-devel] [PATCH 19/21] lustre: obdclass: avoid races in
 class_register_type()
In-Reply-To: <36A43FA1-9CD0-4A9A-BDA4-A184F04B54BE@whamcloud.com>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781342.10620.11880180011933935219.stgit@noble.brown>
 <36A43FA1-9CD0-4A9A-BDA4-A184F04B54BE@whamcloud.com>
Message-ID: <87h8dbgmy8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 08 2019, Andreas Dilger wrote:

> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
>> 
>> If there are two parallel attempts to register the
>> same class name, it could get registered twice.
>> So re-check after allocation to make sure the name is
>> still unique.
>
> The patch itself seems reasonable, but I don't see how this
> scenario could ever happen?  class_register_type() is only
> called once per device type from the module init code, and
> I don't think it is possible to insert the same module twice?

I agree. I don't think it can happen.
By the same logic, the test

	if (class_search_type(name)) {
		CDEBUG(D_IOCTL, "Type %s already registered\n", name);
		return -EEXIST;
	}

at the start of class_register_type() is pointless, as it is not
possible for the same name to be registered twice.

But I think it is still good to have this test, and to fail-safe.
To me the test as it is "looks" prone to races, so I wanted to fix it.
When I'm analysining obscure bugs, it helps a lot to have code that is
"obviously correct" without having the understand (and double check)
various assumptions about usage which are necessary for it to be
correct.

So this patch isn't needed for correctness. It is needed (I think) to
make the code understandable and maintainable.

Thanks,
NeilBrown


>
> Cheers, Andreas
> ---
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/28704704/attachment.sig>
