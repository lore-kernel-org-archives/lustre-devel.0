From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 14 Apr 2017 10:15:34 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: Fix sparse
 endianness warnings cast to restricted __le64 and __le32
In-Reply-To: <1492067363-31101-1-git-send-email-skanda.kashyap@gmail.com>
References: <20170412061549.GB32351@kroah.com>
	<1492067363-31101-1-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <20170414081534.GB16598@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Apr 13, 2017 at 12:09:23AM -0700, skanda.kashyap at gmail.com wrote:
> From: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> Modified struct lu_dirpage in lustre_idl.h file to remove the sparse
> warnings where cast to restricted types are made.
> 
> Following warnings are removed by this fix.
> 
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast to restricted __le64
> 
> Signed-off-by: Skanda Guruanand <skanda.kashyap@gmail.com>
> ---
> Isn't the below reason good enough?
> Since the structure elements are always converted from little endian to processor native format
> in mdc_request.c, struct lu_dirpage element types is modified.

Why isn't this above in the changelog text?

And I need an ack from a lustre maintainer before I can take this...

thanks,

greg k-h
