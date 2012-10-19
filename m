From: Bobi Jam <bobijam@whamcloud.com>
Date: Sat, 20 Oct 2012 01:38:04 +0800
Subject: [Lustre-devel] OSD object questions
In-Reply-To: <1350587734.21354.143.camel@bohr.ornl.gov>
References: <1350587734.21354.143.camel@bohr.ornl.gov>
Message-ID: <299A8FA6-B467-42D8-94BC-8F1CA097B3F7@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

My understanding is that when we allocate top slice object by calling lu_object_alloc(), first it calls its corresponding device's ldo_object_alloc() to create the top slice object, then it go into following code

do {
        /*
         * Call ->loo_object_init() repeatedly, until no more new
         * object slices are created.
         */
        clean = 1;
        cfs_list_for_each_entry(scan, layers, lo_linkage) {
                if (scan->lo_flags & LU_OBJECT_ALLOCATED)
                        continue;
                clean = 0;
                scan->lo_header = top->lo_header;
                result = scan->lo_ops->loo_object_init(env, scan, conf);
                if (result != 0) {
                        lu_object_free(env, top);
                        RETURN(ERR_PTR(result));
                }
                scan->lo_flags |= LU_OBJECT_ALLOCATED;
        }
} while (!clean);

In the first round, the layers list only contains the upper slice it self (scan be the top object), scan->lo_ops->loo_object_init() will go into the <top>_object_init() as you described earlier, it allocate lower slice object and add it into the layers list (by calling lu_object_add()), and scan->lo_flags is set to indicate that the top object has been allocated, this time clean is 0, we will go into the 2nd round of do_while loop.

In the 2nd round, layers list contains top object(flags is set as allocated) and 2nd slice object (flags hasn't be set allocated), clean <- 0 and scan <- 2nd_slice_obj, its loo_object_init() will alloc possible 3rd slice obj, and continue the loop.

If there's no 3rd slice, 2nd_obj->loo_object_init() will just initialise 2nd object itself and not 3rd object be allocated and linked into the layers list (as osc_object_init() shows), and 2nd_obj's flag set to be allocated. And the loop will bail out.

-- 
Best regards,

Bobi Jam     bobijam at whamcloud.com

On Oct 19, 2012, at 3:15 AM, James A Simmons <uja@ornl.gov> wrote:

> The part I had a hard time making out was the 
> lu_object_alloc() function in lu_object.c. You appear to allocate a
> top level lu_object with the low level ldo_object_alloc hook but its a
> freshly created object so I assume because you did add the top object to
> its own list, loh_layer, that the loop you do only contains one object
> but you loop as if alot of lu_objects will be in the loh_layers list
> with some even allocated. Where is that list being set from so the
> properly related objects are initialized? Which objects are being
> initialized? The one's higher in the slice? 
