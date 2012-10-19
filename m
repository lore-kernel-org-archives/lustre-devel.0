From: Alex Zhuravlev <bzzz@whamcloud.com>
Date: Fri, 19 Oct 2012 22:21:47 +0400
Subject: [Lustre-devel] OSD object questions
In-Reply-To: <1350587734.21354.143.camel@bohr.ornl.gov>
References: <1350587734.21354.143.camel@bohr.ornl.gov>
Message-ID: <CAGBrHDtrueDkRBLUBN2dvTnnX1iumkn14Jm2TRfTmxaCuJeH-g@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 18, 2012 at 11:15 PM, James A Simmons <uja@ornl.gov> wrote:
> This is not allocation the zzz_object type that would be allocated by
> zzz_object_alloc but is instead a lower level lu_object type object.
> Would it always one one slice lower or the lowest level i.e lu_object
> itself? Then it forms a compound object with lu_object_add.

In this specific case it's not an object being allocated, it's a slice
- representation
of a specific layer in this object.

> That is the easy part. The part I had a hard time making out was the
> lu_object_alloc() function in lu_object.c. You appear to allocate a
> top level lu_object with the low level ldo_object_alloc hook but its a
> freshly created object so I assume because you did add the top object to
> its own list, loh_layer, that the loop you do only contains one object
> but you loop as if alot of lu_objects will be in the loh_layers list
> with some even allocated. Where is that list being set from so the
> properly related objects are initialized? Which objects are being
> initialized? The one's higher in the slice?

every layer in the stack is represented by a specific device. and that device
is supposed to export ->ldo_object_alloc() method to allocate a slice
of an object
(see above).

then in the loop we basically find not-initialized-yet slices
(!(scan->lo_flags & LU_OBJECT_ALLOCATED)) and call ->loo_object_init() to
initialize the slice. that method in turn is supposed to find layer
below and call
appropriate method to allocate a slice below.

AFAIU, the reason it's done this way is to avoid recursion and make 4K-stack
kernels happy.

probably Jinshan Xiong can help with a good example from CLIO.

thanks, Alex
