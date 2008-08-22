From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Fri, 22 Aug 2008 19:45:57 +0400
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <20080820192922.GG3392@webber.adilger.int>
References: <200808201523.36720.alexander.zarochentsev@sun.com>
	<C4D1B2E1.575A%peter.braam@sun.com>
	<20080820192922.GG3392@webber.adilger.int>
Message-ID: <200808221945.57702.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 20 August 2008 23:29:22 Andreas Dilger wrote:
> On Aug 20, 2008  11:39 -0600, Peter J. Braam wrote:
> > If I remember correctly the flush is only there to try to reduce
> > rollback. However, given that failover may happen on a system where
> > the software is not fully responsive, one could question the wisdom
> > of this reduction.  In any case having more replay due to more
> > rollback is harmless.
> >
> > I do not see a problem removing this, and I would avoid making it
> > an option.
>
> One major caveat is that with mountconf we ALWAYS mark the device as
> "readonly" when it is being unmounted.
> If we don't have the sync 
> there I fear data loss after a clean server unmount, when all clients
> are also being unmounted and cannot do replay.
>
> I'd be thrilled if this was fixed so a normal shutdown did not do a
> "force" unmount and set the device read-only, because that would also
> avoid leaving the journal needing recovery.

I think the proposed changes do not touch umount or mountconf.
The affected procedures are:

1. obd_fail_write calls lvfs_set_rdonly    
	-- IMO it might be better to not sync device there.
2. filter_iocontrol -> lvfs_set_rdonly  
	-- not changed, there is filter_sync() call right before
           lvfs_set_readonly
3. mdt_iocontrol -> dt_ro/osd_ro -> __lvfs_set_rdonly
        -- it is what I want to change
4. mdt_fail_write -> dt_ro/osd_ro -> __lvfs_set_rdonly
        -- sync is needed?

Here is the patch:
---
Index: lustre/lvfs/lvfs_linux.c
===================================================================
RCS file: /cvsroot/cfs/lustre-core/lvfs/lvfs_linux.c,v
retrieving revision 1.41
diff -u -p -r1.41 lvfs_linux.c
--- lustre/lvfs/lvfs_linux.c	7 Aug 2008 14:50:49 -0000	1.41
+++ lustre/lvfs/lvfs_linux.c	22 Aug 2008 14:35:23 -0000
@@ -476,7 +476,6 @@ int dev_check_rdonly(lvfs_sbdev_type dev
 
 void __lvfs_set_rdonly(lvfs_sbdev_type dev, lvfs_sbdev_type jdev)
 {
-        lvfs_sbdev_sync(dev);
         if (jdev && (jdev != dev)) {
                 CDEBUG(D_IOCTL | D_HA, "set journal dev %lx rdonly\n",
                        (long)jdev);
Index: lustre/mdt/mdt_handler.c
===================================================================
RCS file: /cvsroot/cfs/lustre-core/mdt/mdt_handler.c,v
retrieving revision 1.46
diff -u -p -r1.46 mdt_handler.c
--- lustre/mdt/mdt_handler.c	7 Aug 2008 16:52:04 -0000	1.46
+++ lustre/mdt/mdt_handler.c	22 Aug 2008 14:35:26 -0000
@@ -4630,7 +4716,6 @@ static int mdt_iocontrol(unsigned int cm
                 rc = dt->dd_ops->dt_sync(&env, dt);
                 break;
         case OBD_IOC_SET_READONLY:
-                rc = dt->dd_ops->dt_sync(&env, dt);
                 dt->dd_ops->dt_ro(&env, dt);
                 break;
         case OBD_IOC_ABORT_RECOVERY:
Index: lustre/tests/test-framework.sh
===================================================================
RCS file: /cvsroot/cfs/lustre-core/tests/test-framework.sh,v
retrieving revision 1.119
diff -u -p -r1.119 test-framework.sh
--- lustre/tests/test-framework.sh	5 Aug 2008 21:31:26 -0000	1.119
+++ lustre/tests/test-framework.sh	22 Aug 2008 14:35:34 -0000
@@ -770,6 +770,16 @@ replay_barrier_nodf() {
     $LCTL mark "local REPLAY BARRIER on ${!svc}"
 }
 
+replay_barrier_nosync() {
+    local facet=$1    echo running=${running}
+    local svc=${facet}_svc
+    echo Replay barrier on ${!svc}
+    do_facet $facet $LCTL --device %${!svc} readonly
+    do_facet $facet $LCTL --device %${!svc} notransno
+    do_facet $facet $LCTL mark "$facet REPLAY BARRIER on ${!svc}"
+    $LCTL mark "local REPLAY BARRIER on ${!svc}"
+}
+
 mds_evict_client() {
     UUID=`lctl get_param -n mdc.${mds1_svc}-mdc-*.uuid`
     do_facet mds1 "lctl set_param -n mdt.${mds1_svc}.evict_client 
$UUID"

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
