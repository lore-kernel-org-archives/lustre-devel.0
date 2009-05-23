From: Andreas Dilger <adilger@sun.com>
Date: Sat, 23 May 2009 09:48:58 -0600
Subject: [Lustre-devel] new to lustre and bug 18539
In-Reply-To: <alpine.LFD.2.00.0905191416100.22823@casper.infradead.org>
References: <alpine.LFD.2.00.0905191416100.22823@casper.infradead.org>
Message-ID: <20090523154858.GB19035@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 21, 2009  15:46 +0100, James Simmons wrote:
> 	For my first dive into the code I'm tackling bug 18539. Of course 
> looking at the code base opened up alot of questions. Looking at what was
> recommended by Andreas Dilger was to make use of the oscc_flags. The other 
> part of the solution was to bump up the return value of osc_precreate.

There are several parts to fixing this bug:
1. have the OSC extract the os_state flags from the obd_statfs struct
  * this can be done in the osc_statfs_interpret() function, which is
    registered as the RPC completion callback from osc_statfs_async()
  - there is the OS_STATE_READONLY which we already return in os_state
    if the filesystem has detected an error and remounted read-only.
    This can use a new OSCC_FLAG_RDONLY flag.
  - the OS_STATE_DEGRADED flag would need to be set for degraded OSTs (see 3.),
    and should get a new OSCC_FLAG_DEGRADED flag.
  - the place to hold these returned states is in oscc_flags, which is what
    the OSC object creation code uses to track its state
2. have the OSC object creation code check for the OSCC_FLAG_RDONLY and
   OSCC_FLAG_DEGRADED flags.
   - use OSCC_FLAG_NOSPC as a template for the OSCC_FLAG_RDONLY behaviour,
     since the code needs to be changed in many of the same places.
     - current code uses OSCC_FLAG_NOSPC in the case of EROFS returns from
       object precreation, but this isn't really correct as OSCC_FLAG_NOSPC
       is incorrectly cleared in osc_set_info_async when a file is unlinked
       even if the filesystem is read only.  I'm filing a separate bug
       to fix this issue.
   - in osc_precreate() it should check for OSCC_FLAG_DEGRADED and also
     OSCC_FLAG_ROFS and OSCC_FLAG_NOSPC.  For ROFS it should treat it like
     NOSPC (return 1000).  For DEGRADED it should return 2 (functional but
     not preferred for allocation).
3. having the OST notice that the LUN is degraded
  - add a /proc/fs/lustre/obdfilter/{OST}/degraded file
  - (separately) we would want to have this automated for MD RAID devices
    but that doesn't need to be part of this patch
  - in statfs it should check for this and return this state via os_state

> 	My first set of questions delas with the places where the 
> oscc_flag is used in some fashion. I noticed one spot for its use was 
> osc_set_info_async. Looking through the code it appears to be only called 
> by a osc shrink grant which itself appears to happen on a osc disconnect.
> This is correct or is this function used in other places? The next 
> question is about osc_import_events. Does this function handle events 
> coming from multiple sources, clients, mds, ost? Also are these events
> the type that are sent out when a state changes versus someone sending a 
> rpc to request the state? 
> 	My second set of questions deals with osc_statfs*. From the notes
> in the bugzilla osc_statfs_interpret is a MDS side function. Looking at 
> the code I noticed it is the call back to osc_statfs_async. Knowing 
> that osc_statfs_async is a obd_ops and thus has a wrapper, obd_statfs_async.
> I scanning the code for this and noticed that this wrapper used with the 
> proper obd_device for the osc was used in the lov layer. The two areas in 
> the lov layer where lov_statfs_async and qos_statfs_update handled this.
> If I remember right this is on the client side of the code. Where does the 
> mds fit into this? Lov_statfs_async is for when the client queries data 
> about the file. Whereas qos_statfs_update is what is called durning 
> inital file create or when the statfs info is to old. Please correct me if 
> I'm wrong. 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
