From: Greg KH <greg@kroah.com>
Date: Fri, 16 Oct 2015 22:21:05 -0700
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: remove IS_PO2 and
	__is_po2
In-Reply-To: <97ba103dc2a11e23fd4a384eb041c273b67a9aee.1445032901.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
	<97ba103dc2a11e23fd4a384eb041c273b67a9aee.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <20151017052105.GA10998@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 17, 2015 at 12:07:28AM +0200, Aya Mahfouz wrote:
> Removes IS_PO2 and __is_po2 since the uses of IS_PO2 have
> been replaced by is_power_of_2
> 
> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> ---
>  drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
>  1 file changed, 7 deletions(-)

You didn't test build this patch :(
