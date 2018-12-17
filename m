From: NeilBrown <neilb@suse.com>
Date: Tue, 18 Dec 2018 10:54:41 +1100
Subject: [lustre-devel] [PATCH 01/28] lustre: pfl: Basic data structures
 for composite layout
In-Reply-To: <1545064202-22483-2-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87va3raev2.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 17 2018, James Simmons wrote:

> From: Niu Yawei <yawei.niu@intel.com>
>
> Added basic structures and magic numbers for composite layout.
>

This would be a great place to (brief) explain what PFL does and what it
is going to do with this data structures.
What are the "components" and how do they form a "composite layout" ??

> +
> +enum lov_comp_md_entry_flags {
> +	LCME_FL_PRIMARY		= 0x00000001,   /* Not used */
> +	LCME_FL_STALE		= 0x00000002,   /* Not used */
> +	LCME_FL_OFFLINE		= 0x00000004,   /* Not used */
> +	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
> +	LCME_FL_INIT		= 0x00000010,	/* instantiated */
> +};
> +
> +#define LCME_KNOWN_FLAGS	LCME_FL_INIT

What is a "KNOWN" flags?  What isn't known about the other ones?

> +
> +/* lcme_id can be specified as certain flags, and the the first
                                                     ^^^^^^^
Too many "the"s.                                                     

> + * bit of lcme_id is used to indicate that the ID is representing
> + * certain LCME_FL_* but not a real ID. Which implies we can have
> + * at most 31 flags (see LCME_FL_XXX).
> + */
> +enum lcme_id {
> +	LCME_ID_INVAL	= 0x0,
> +	LCME_ID_MAX	= 0x7FFFFFFF,
> +	LCME_ID_ALL	= 0xFFFFFFFF,
> +	LCME_ID_NONE	= 0x80000000
> +};
> +
> +#define LCME_ID_MASK	LCME_ID_MAX

Why is MASK a #define, but MAX an enum ??

> +
> +struct lov_comp_md_entry_v1 {
> +	__u32			lcme_id;	/* unique id of component */
> +	__u32			lcme_flags;	/* LCME_FL_XXX */
> +	struct lu_extent	lcme_extent;	/* file extent for component */
> +	__u32			lcme_offset;	/* offset of component blob,
> +						 * start from lov_comp_md_v1
> +						 */
> +	__u32			lcme_size;	/* size of component blob */
> +	__u64			lcme_padding[2];
> +} __packed;
> +
> +enum lov_comp_md_flags;

This enum is empty, and never used.

It eventually gets some LCM_FL_* names added... maybe it should wait
until those are added??

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181218/c1c61bb3/attachment.sig>
