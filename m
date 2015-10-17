From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 17 Oct 2015 11:54:22 +0200
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: remove IS_PO2 and
	__is_po2
In-Reply-To: <20151017052105.GA10998@kroah.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<97ba103dc2a11e23fd4a384eb041c273b67a9aee.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<20151017052105.GA10998@kroah.com>
Message-ID: <20151017095422.GA29503@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Oct 16, 2015 at 10:21:05PM -0700, Greg KH wrote:
> On Sat, Oct 17, 2015 at 12:07:28AM +0200, Aya Mahfouz wrote:
> > Removes IS_PO2 and __is_po2 since the uses of IS_PO2 have
> > been replaced by is_power_of_2
> > 
> > Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> > ---
> >  drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
> >  1 file changed, 7 deletions(-)
> 
> You didn't test build this patch :(

I think I'm too old for this mistake. The way kbuild tests patch sets
will cause errors for sure. It tests every patch independently and of
course the removal of IS_PO2 will cause a problem if the previous
patches were not applied.

-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
