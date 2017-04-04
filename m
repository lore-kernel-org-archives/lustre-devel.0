From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 4 Apr 2017 07:34:55 +0200
Subject: [lustre-devel] [PATCH v2] Remove sparse warnings in
	mdc_request.c
In-Reply-To: <1491283537-13023-1-git-send-email-skanda.kashyap@gmail.com>
References: <1592C3AC-DE8B-4A11-8053-02B82A61E1B3@intel.com>
	<1491283537-13023-1-git-send-email-skanda.kashyap@gmail.com>
Message-ID: <20170404053455.GA9895@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Apr 03, 2017 at 10:25:37PM -0700, skanda.kashyap at gmail.com wrote:
> From: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> Signed-off-by: Skanda Guruanand <skanda.kashyap@gmail.com>
> 
> I have modified  struct lu_dirpage as suggested in lustre_idl.h file
> 
> CHECK   drivers/staging/lustre/lustre/mdc/mdc_request.c
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast
> to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast
> to restricted __le64
> 
> ---
>  drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

What changed from v1?

Always put that here below the --- line.

v3?

thanks,

greg k-h
