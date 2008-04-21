From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 21 Apr 2008 15:08:18 +0400
Subject: [Lustre-devel] New Pools DLD
In-Reply-To: <20080419002217.GC2775@webber.adilger.int>
References: <20080225100425.GC3108@webber.adilger.int>
	<18373.20125.724151.421930@gargle.gargle.HOWL>
	<20080419002217.GC2775@webber.adilger.int>
Message-ID: <18444.30114.732662.996066@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger writes:
 > On Feb 27, 2008  14:50 +0300, Nikita Danilov wrote:
 > > Andreas Dilger writes:
 > > > are you aware of any desirable LOV EA changes that would be good to
 > > > include with the changes for the v3 "pool" EA (attached)?  Are there
 > > > any changes that are desirable for e.g. FIDs or similar?
 > > 
 > > I think that if we are introducing incompatible LOV EA format, we can as
 > > well go forward with changes hinted to at
 > > 
 > > http://arch.lustre.org/index.php?title=MDS_striping_format#Future_developments
 > 
 > Nikita, sorry to take a long time to get back to this issue, but I think
 > it is quite valuable to pursue if we are already going to change the
 > on-disk format.
 > 
 > Since we are already need to change the LOV_MAGIC value, we may as well
 > do as you suggest and have 0x0BD3ssss instead of 0x0BD30BD0, where
 > ssss = size of EA in bytes.
 > 
 > That would limit us to a 65536-byte striping EA, but it still larger than

If that happens to be a limiting factor, we can interpret ssss as a
number of __u32's or __u64's in EA.

 > what is supported today, and the plans for wide striping also do not call
 > for larger EAs.  Even supporting 64kB EAs  would be an issue with the
 > current nifrastructure because the client always has to preallocate a
 > receive buffer large enough for the largest EA because it does not know
 > the EA size in advance.
 > 
 > The question is whether you think we should also add a magic + size to the
 > lov_ost_data_v1 structure, which is currently the same for all EA types.
 > Adding a per-stripe magic + size would reduce the number of stripes we
 > can allocate per file, and the 160-stripe limit is already a problem for
 > some systems with more than 160 OSTs.

I think we need an ability to have fully general files layout, so that,
for example, a stripe can in turn be a striped file. This can be
something like

struct lov_mds_md_v3 {
        __u32 lmm_magic;          /* 0x0BD3ssss */
        __u32 lmm_pattern;        /* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
        __u64 lmm_object_id;      /* LOV object ID */
        __u64 lmm_object_gr;      /* LOV object group */
        __u32 lmm_stripe_size;    /* size of stripe in bytes */
        __u32 lmm_stripe_count;   /* num stripes in use for this object */
};

followed by a sequence of stripe layout descriptors each starting with

        __u32 magic; /* 0xLLLLSSSS. where LLLL is an identifier of a
                      * layout type (e.g., 0bd3 is raid0 or raid1), and
                      * SSSS is a size. */

But for a common case of a striped file where all stripes have the same
layout, we implement a short-cut:

struct lov_mds_md_v4 {
        __u32 lmm_magic;          /* 0x0BD4ssss */
        __u32 lmm_pattern;        /* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
        __u64 lmm_object_id;      /* LOV object ID */
        __u64 lmm_object_gr;      /* LOV object group */
        __u32 lmm_stripe_size;    /* size of stripe in bytes */
        __u32 lmm_stripe_count;   /* num stripes in use for this object */
        __u32 lmm_stripe_magic;   /* 0xLLLLSSSS for all stripes */
};

followed by an array of stripe layout descriptor, stripped of their
magics.

Or we can go one step further and assume particular value of
lmm_stripe_magic for a particular lmm_magic. In this case,
->lmm_stripe_magic field can be removed.

 > 
 > Cheers, Andreas
 > --

Nikita.
