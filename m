From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 16 Jun 2015 15:21:58 +0000
Subject: [lustre-devel] HSM phase 2 HLD / Roadmap?
In-Reply-To: <55803C06.4080003@cea.fr>
References: <CAPALmnnUyFxT3zwJUZ5ZGkgeHO9XgdQqPFTQ_chqy5wmLmEkwg@mail.gmail.com>
	<55803C06.4080003@cea.fr>
Message-ID: <D1A5987F.F7ACA%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think there are a few features that would be of interest for HSM
improvement.

* optimization of RobinHood database/POSIX copytool
* better integration with DNE
* partial file restore using composite files
(http://wiki.opensfs.org/images/e/e4/LayoutEnhancementDesign_HighLevelDesig
n.pdf)
   * change HSM to use LOV EA layout instead of dedicated xattr
   * allowing a larger HSM archive ID (e.g. 128-bit UUID) so it can be
     used as the primary archive identifier instead of Lustre FID
* archive/restore of directory trees from the MDT as tarballs
   * allow release/restore of space from the MDT
   * would be needed for handling Data-on-MDT files

Note that we don't have any plans to work on this, just listing some ideas
percolating in my brain.


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division



On 2015/06/16, 9:08 AM, "DEGREMONT Aurelien" <aurelien.degremont@cea.fr>
wrote:


>Le 16/06/2015 17:02, Colin Faber a ?crit :
>
>
>Hi Folks,
>
>Does anyone recall if Lustre HSM phase 2 documentation or road map was
>ever produced / published anywhere?
>
>
>
>AFAICR there never was a real official content for HSM phase 2, just
>ideas/wish list. As a consequence, no road map was done.
>
>
>Aur?lien
