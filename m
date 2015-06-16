From: Patrick Farrell <paf@cray.com>
Date: Tue, 16 Jun 2015 10:28:53 -0500
Subject: [lustre-devel] HSM phase 2 HLD / Roadmap?
In-Reply-To: <D1A5987F.F7ACA%andreas.dilger@intel.com>
References: <CAPALmnnUyFxT3zwJUZ5ZGkgeHO9XgdQqPFTQ_chqy5wmLmEkwg@mail.gmail.com>
	<55803C06.4080003@cea.fr> <D1A5987F.F7ACA%andreas.dilger@intel.com>
Message-ID: <558040B5.2050609@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

Could you expound on "Better integration with DNE"?  I'm not immediately 
clear on what that might mean.

Thanks,
- Patrick
On 06/16/2015 10:21 AM, Dilger, Andreas wrote:
> I think there are a few features that would be of interest for HSM
> improvement.
>
> * optimization of RobinHood database/POSIX copytool
> * better integration with DNE
> * partial file restore using composite files
> (http://wiki.opensfs.org/images/e/e4/LayoutEnhancementDesign_HighLevelDesig
> n.pdf)
>     * change HSM to use LOV EA layout instead of dedicated xattr
>     * allowing a larger HSM archive ID (e.g. 128-bit UUID) so it can be
>       used as the primary archive identifier instead of Lustre FID
> * archive/restore of directory trees from the MDT as tarballs
>     * allow release/restore of space from the MDT
>     * would be needed for handling Data-on-MDT files
>
> Note that we don't have any plans to work on this, just listing some ideas
> percolating in my brain.
>
>
> Cheers, Andreas
