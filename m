From: NeilBrown <neilb@suse.com>
Date: Fri, 16 Mar 2018 14:47:48 +1100
Subject: [lustre-devel] mmotm 2018-03-14-16-24 uploaded (lustre)
In-Reply-To: <5c65e935-a6d9-2f80-18ac-470ed38ba439@infradead.org>
References: <20180314232442.rL_lhWQqT%akpm@linux-foundation.org>
 <5c65e935-a6d9-2f80-18ac-470ed38ba439@infradead.org>
Message-ID: <87605wbs0r.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, lustre-devel@lists.lustre.org

On Thu, Mar 15 2018, Randy Dunlap wrote:

> On 03/14/2018 04:24 PM, akpm at linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2018-03-14-16-24 has been uploaded to
>> 
>>    http://www.ozlabs.org/~akpm/mmotm/
>
> (not from the mmotm patches, but in its linux-next.patch)
>
> CONFIG_LUSTRE_FS=y
> # CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is not set
>
>
> In file included from ../drivers/staging/lustre/include/linux/libcfs/libcfs.h:42:0,
>                  from ../drivers/staging/lustre/lustre/obdclass/lu_object.c:44:
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_context_key_degister':
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1410:51: error: dereferencing pointer to incomplete type
>           __func__, key->lct_owner ? key->lct_owner->name : "",
>                                                    ^

Thanks for the report.
Arnd Bergmann posted a patch to fix this on Tuesday

Message-Id: <20180313130425.3975930-1-arnd@arndb.de>

http://lkml.kernel.org/r/<20180313130425.3975930-1-arnd@arndb.de>

so the error should disappear soon.

Thanks,
NeilBrown


> ../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: note: in definition of macro '__CDEBUG'
>    libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
>                                          ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1409:3: note: in expansion of macro 'CDEBUG'
>    CDEBUG(D_INFO, "%s: \"%s\" %p, %d\n",
>    ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_context_key_quiesce':
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1550:42: error: dereferencing pointer to incomplete type
>            key->lct_owner ? key->lct_owner->name : "",
>                                           ^
> ../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: note: in definition of macro '__CDEBUG'
>    libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
>                                          ^
> ../drivers/staging/lustre/lustre/obdclass/lu_object.c:1548:4: note: in expansion of macro 'CDEBUG'
>     CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
>     ^
>
>
>
> -- 
> ~Randy
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180316/1b7580c6/attachment.sig>
