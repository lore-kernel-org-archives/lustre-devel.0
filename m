From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 20 Oct 2012 08:18:23 +0000
Subject: [Lustre-devel] OSD object questions
In-Reply-To: <1350587466.21354.141.camel@bohr.ornl.gov>
References: <1350587466.21354.141.camel@bohr.ornl.gov>
Message-ID: <D6EA5741-C1B7-4A26-AE14-5C4D87D2BCE7@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-10-18, at 13:11, James A Simmons <uja@ornl.gov> wrote:
> 
>        I have started the process of learning the new OSD design and
> have a
> few questions after reading the osd-api document as well as the code.

James, I'd encourage you to collect your notes and update any gaps in the OSD API doc as much as you can. Often, since the people writing the doc are the experts, they don't see where there are gaps in the explanations. 

Please note that the doc was originally focussed on the sever stack, in order to allow someone to write a new OSD driver, so the client IO usage and implementation that you discuss below is not necessarily covered.

There were also notes from Nikita about CLIO that could also be updated and included into this docs directory. 

Cheers, Andreas

> The questions center around the OSD Objects which is described by
> struct lu_object. Now each object is described as being represented by a
> header (lu_header) and slices. Also the code refers to the concept of
> compound objects. Now if I'm understanding this correctly then a perfect
> example of a compound object is struct lovsub_object which is a super
> class of lu_object composed of two other classes. Now in this exmaple
> class lso_cl would be considered one of the allocated slices in the
> lu_object stack. Same for lso_super. Then for lov_object lo_cl would be
> a slice etc until we hit the bottom of the stack at the base class
> lu_object.
> 
> struct lovsub_object {
>        ...
>        struct cl_object        lso_cl;
>        struct lov_object      *lso_super;
>        ...
> }
> 
> struct lov_object {
>        struct cl_object lo_cl;
>        ...
> 
> 
> strict cl_object {
>        struct lu_object co_lu; 
>        ..
> }
> 
> struct lu_object {
>        struct lu_header lo_header;
>        ...
> }
> 
> Now let see if I'm interrupting this correctly. I noticed many
> of the zzz_object_init functions for lu_object_operations have
> a format similar to :
> 
> static int zzz_object_init(const struct lu_env *env,
>                           struct lu_object *o,
>                           const struct lu_object_conf *conf)
> {
>        struct zzz_device *d = lu2zzz_dev(o->lo_dev);
>        struct lu_device  *under;
>        struct lu_object  *below;
>        int                rc = 0;
>        ENTRY;
> 
>        under = &d->yyy->dd_lu_dev;
>        below = under->ld_ops->ldo_object_alloc(env, o->lo_header,
> under);
>        if (below != NULL)
>                lu_object_add(o, below);
>        else
>                rc = -ENOMEM;
> 
>        return 0;
> }
> 
> This is not allocation the zzz_object type that would be allocated by
> zzz_object_alloc but is instead a lower level lu_object type object.
> Would it always one one slice lower or the lowest level i.e lu_object
> itself? Then it forms a compound object with lu_object_add.
> 
> That is the easy part. The part I had a hard time making out was the 
> lu_object_alloc() function in lu_object.c. You appear to allocate a
> top level lu_object with the low level ldo_object_alloc hook but its a
> freshly created object so I assume because you did add the top object to
> its own list, loh_layer, that the loop you do only contains one object
> but you loop as if alot of lu_objects will be in the loh_layers list
> with some even allocated. Where is that list being set from so the
> properly related objects are initialized? Which objects are being
> initialized? The one's higher in the slice? 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
