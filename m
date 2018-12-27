From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 01:57:03 +0000 (GMT)
Subject: [lustre-devel] [PATCH 01/28] lustre: pfl: Basic data structures
 for composite layout
In-Reply-To: <87va3raev2.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-2-git-send-email-jsimmons@infradead.org>
 <87va3raev2.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1812270153560.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > From: Niu Yawei <yawei.niu@intel.com>
> >
> > Added basic structures and magic numbers for composite layout.
> >
> 
> This would be a great place to (brief) explain what PFL does and what it
> is going to do with this data structures.
> What are the "components" and how do they form a "composite layout" ??

Would the link - http://wiki.lustre.org/PFL_Prototype_High_Level_Design
be enough ?
 
> > +
> > +enum lov_comp_md_entry_flags {
> > +	LCME_FL_PRIMARY		= 0x00000001,   /* Not used */
> > +	LCME_FL_STALE		= 0x00000002,   /* Not used */
> > +	LCME_FL_OFFLINE		= 0x00000004,   /* Not used */
> > +	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
> > +	LCME_FL_INIT		= 0x00000010,	/* instantiated */
> > +};
> > +
> > +#define LCME_KNOWN_FLAGS	LCME_FL_INIT
> 
> What is a "KNOWN" flags?  What isn't known about the other ones?

Patrick answered this one :-)

> > + * bit of lcme_id is used to indicate that the ID is representing
> > + * certain LCME_FL_* but not a real ID. Which implies we can have
> > + * at most 31 flags (see LCME_FL_XXX).
> > + */
> > +enum lcme_id {
> > +	LCME_ID_INVAL	= 0x0,
> > +	LCME_ID_MAX	= 0x7FFFFFFF,
> > +	LCME_ID_ALL	= 0xFFFFFFFF,
> > +	LCME_ID_NONE	= 0x80000000
> > +};
> > +
> > +#define LCME_ID_MASK	LCME_ID_MAX
> 
> Why is MASK a #define, but MAX an enum ??

Actually I looked and this mask is only needed for server code. Sadly 
developers are still using lustre_idl.h and lustre_user.h as dumpsters :-(
Will remove.

> > +
> > +struct lov_comp_md_entry_v1 {
> > +	__u32			lcme_id;	/* unique id of component */
> > +	__u32			lcme_flags;	/* LCME_FL_XXX */
> > +	struct lu_extent	lcme_extent;	/* file extent for component */
> > +	__u32			lcme_offset;	/* offset of component blob,
> > +						 * start from lov_comp_md_v1
> > +						 */
> > +	__u32			lcme_size;	/* size of component blob */
> > +	__u64			lcme_padding[2];
> > +} __packed;
> > +
> > +enum lov_comp_md_flags;
> 
> This enum is empty, and never used.
> 
> It eventually gets some LCM_FL_* names added... maybe it should wait
> until those are added??

Also removed. Strange this exist in the 2.10 branch but its not used.
