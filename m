From: NeilBrown <neilb@suse.com>
Date: Wed, 18 Apr 2018 12:33:39 +1000
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: remove
 include/linux/libcfs/linux/linux-cpu.h
In-Reply-To: <alpine.LFD.2.21.1804160448410.16188@casper.infradead.org>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935737.23409.2271901486597092772.stgit@noble>
 <alpine.LFD.2.21.1804160448410.16188@casper.infradead.org>
Message-ID: <871sfds0os.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16 2018, James Simmons wrote:

>> This include file contains definitions used when CONFIG_SMP
>> is in effect.  Other includes contain corresponding definitions
>> for when it isn't.
>> This can be hard to follow, so move the definitions to the one place.
>> 
>> As HAVE_LIBCFS_CPT is defined precisely when CONFIG_SMP, we discard
>> that macro and just use CONFIG_SMP when needed.
>
> Nak. The lustre SMP is broken and needed to badly be reworked. I have it 
> ready and can push it. I was waiting to see if I had to rebase it once
> the rc1 stuff but since their is a push to get everything out their I will
> push it.
>

Great - thanks for posting those.  I might wait until they land in
Greg's tree, then see if I there is anything else I want to add.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180418/588bf89a/attachment.sig>
