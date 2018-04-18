From: NeilBrown <neilb@suse.com>
Date: Wed, 18 Apr 2018 12:32:01 +1000
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: remove
 libcfs/linux/libcfs.h
In-Reply-To: <alpine.LFD.2.21.1804160431550.16188@casper.infradead.org>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935734.23409.11654775387996961581.stgit@noble>
 <alpine.LFD.2.21.1804160431550.16188@casper.infradead.org>
Message-ID: <874lk9s0ri.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16 2018, James Simmons wrote:

>> This include file is only included in one place,
>> and only contains a list of other include directives.
>> So just move all those to the place where this file
>> is included, and discard the file.
>> 
>> One include directive uses a local name ("linux-cpu.h"), so
>> that needs to be given a proper path.
>> 
>> Probably many of these should be remove from here, and moved to
>> just the files that need them.
>
> Nak. Dumping all the extra headers from linux/libcfs.h to libcfs.h is
> the wrong approach. The one header, libcfs.h, to be the only header
> in all lustre files is the wrong approach. I have been looking to
> unroll that mess. I have patch that I need to polish you that I can
> submit.

I think we both have the same goal - maybe just different paths to get
there.  If you have something nearly ready to submit, I'm happy to wait
for it, then proceed on top of it.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180418/eacafe88/attachment.sig>
