From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 6 Nov 2015 17:11:09 -0800
Subject: [lustre-devel] [PATCH v3 5/5] staging: lustre: libcfs.h: remove
 IS_PO2 and __is_po2
In-Reply-To: <6257d068b94ff8b07a6c756df16325fea0e7536f.1446079745.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
	<6257d068b94ff8b07a6c756df16325fea0e7536f.1446079745.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <20151107011109.GB7495@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 29, 2015 at 03:00:24AM +0200, Aya Mahfouz wrote:
> Removes IS_PO2 and __is_po2 since the uses of IS_PO2 have
> been replaced by is_power_of_2
> 
> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> ---
> v2:
>         -became patch number 5 in the series
> v3:
> 	-no change
> 
>  drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
>  1 file changed, 7 deletions(-)

I can't take this yet, as your patch 2/5 didn't apply :(
