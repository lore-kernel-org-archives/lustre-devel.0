From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 7 Nov 2015 12:03:41 +0200
Subject: [lustre-devel] [PATCH v3 5/5] staging: lustre: libcfs.h: remove
 IS_PO2 and __is_po2
In-Reply-To: <20151107011109.GB7495@kroah.com>
References: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
	<6257d068b94ff8b07a6c756df16325fea0e7536f.1446079745.git.mahfouz.saif.elyazal@gmail.com>
	<20151107011109.GB7495@kroah.com>
Message-ID: <20151107100341.GA2852@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 06, 2015 at 05:11:09PM -0800, Greg KH wrote:
> On Thu, Oct 29, 2015 at 03:00:24AM +0200, Aya Mahfouz wrote:
> > Removes IS_PO2 and __is_po2 since the uses of IS_PO2 have
> > been replaced by is_power_of_2
> > 
> > Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> > ---
> > v2:
> >         -became patch number 5 in the series
> > v3:
> > 	-no change
> > 
> >  drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
> >  1 file changed, 7 deletions(-)
> 
> I can't take this yet, as your patch 2/5 didn't apply :(

No, problems. I understand that it is hard for these patches to apply as
is given that they are quite old. I will recheck if there are new uses
of them and resend this patch alone or in another patchset.

Thanks,

-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
