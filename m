From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Jun 2018 09:21:37 +1000
Subject: [lustre-devel] [PATCH 11/11] staging: lustre: centralize
 setting of subdir-ccflags-y
In-Reply-To: <alpine.LFD.2.21.1806132237140.12664@casper.infradead.org>
References: <152826510267.16761.14361003167157833896.stgit@noble>
 <152826511930.16761.12770722873423628004.stgit@noble>
 <alpine.LFD.2.21.1806132237140.12664@casper.infradead.org>
Message-ID: <871sdai872.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jun 13 2018, James Simmons wrote:

>> We don't need to set subdir-ccflags-y in every Makefile.
>> The whole point of the "subdir-" bit is that the setting
>> can go once in the top-level Makefile.
>> 
>
> Nak: When attempting to build individual components I get:
>
> ~/lustre-upstream$ make SUBDIRS=drivers/staging/lustre/lustre/lmv modules 
> -j 16
>
>   WARNING: Symbol version dump ./Module.symvers
>            is missing; modules will have no dependencies and modversions.
>
>   CC [M]  drivers/staging/lustre/lustre/lmv/lmv_obd.o
>   CC [M]  drivers/staging/lustre/lustre/lmv/lmv_intent.o
>   CC [M]  drivers/staging/lustre/lustre/lmv/lmv_fld.o
>   CC [M]  drivers/staging/lustre/lustre/lmv/lproc_lmv.o
> drivers/staging/lustre/lustre/lmv/lproc_lmv.c:38:28: fatal error: 
> lprocfs_status.h: No such file or directory
>  #include <lprocfs_status.h>
>                             ^
> compilation terminated.

Yes, I noticed that too.  Thanks.
It seems to suggest that subdir-ccflags-y isn't really a useful macro.
Maybe we should stick with cc-flags-y.  It is much more widely used.

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180614/68f87a5a/attachment.sig>
