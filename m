From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 15 Mar 2018 10:17:52 -0700
Subject: [lustre-devel] mmotm 2018-03-14-16-24 uploaded (lustre)
In-Reply-To: <20180314232442.rL_lhWQqT%akpm@linux-foundation.org>
References: <20180314232442.rL_lhWQqT%akpm@linux-foundation.org>
Message-ID: <5c65e935-a6d9-2f80-18ac-470ed38ba439@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, lustre-devel@lists.lustre.org

On 03/14/2018 04:24 PM, akpm at linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-03-14-16-24 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/

(not from the mmotm patches, but in its linux-next.patch)

CONFIG_LUSTRE_FS=y
# CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is not set


In file included from ../drivers/staging/lustre/include/linux/libcfs/libcfs.h:42:0,
                 from ../drivers/staging/lustre/lustre/obdclass/lu_object.c:44:
../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_context_key_degister':
../drivers/staging/lustre/lustre/obdclass/lu_object.c:1410:51: error: dereferencing pointer to incomplete type
          __func__, key->lct_owner ? key->lct_owner->name : "",
                                                   ^
../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: note: in definition of macro '__CDEBUG'
   libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
                                         ^
../drivers/staging/lustre/lustre/obdclass/lu_object.c:1409:3: note: in expansion of macro 'CDEBUG'
   CDEBUG(D_INFO, "%s: \"%s\" %p, %d\n",
   ^
../drivers/staging/lustre/lustre/obdclass/lu_object.c: In function 'lu_context_key_quiesce':
../drivers/staging/lustre/lustre/obdclass/lu_object.c:1550:42: error: dereferencing pointer to incomplete type
           key->lct_owner ? key->lct_owner->name : "",
                                          ^
../drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h:123:41: note: in definition of macro '__CDEBUG'
   libcfs_debug_msg(&msgdata, format, ## __VA_ARGS__); \
                                         ^
../drivers/staging/lustre/lustre/obdclass/lu_object.c:1548:4: note: in expansion of macro 'CDEBUG'
    CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
    ^



-- 
~Randy
