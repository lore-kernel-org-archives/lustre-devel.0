From: Andreas Dilger <adilger@sun.com>
Date: Tue, 08 Jul 2008 14:38:05 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <4873A38C.4040507@sun.com>
References: <48728D97.1020704@psc.edu> <4873A38C.4040507@sun.com>
Message-ID: <20080708203805.GS6239@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Benjamin Bennett wrote:
>   For Lustre-WAN across TeraGrid we were hoping to distribute OSSs 
> across several resource providers (sites), leveraging existing kerberos 
> infrastructure, placing OSSs in each resource provider's local kerberos 
> realm, and the MDS in the teragrid realm.  Unfortunately, MDT -> OST 
> connections will not allow the MDT and OST to be in different realms, 
> since an OSS considers an MDS to be anyone holding a lustre_mds 
> principal in their local realm.

As an FYI, you should follow the work being done on OST pools (bug 14836
and its decendants), which will allow users to specify subsets of the
OSTs to store files.  This would allow users to save output files only to
local OSTs for jobs being run at some site, but they could still access
input files from any OSTs transparently (albeit more slowly over a WAN
connection).  This feature is expected to be in the 1.8 release.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
