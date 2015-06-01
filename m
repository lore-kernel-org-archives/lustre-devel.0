From: Greg KH <greg@kroah.com>
Date: Mon, 1 Jun 2015 21:07:03 +0900
Subject: [lustre-devel] [PATCH] staging: lustre: cleanup not needed else
	clauses
In-Reply-To: <1433143750-13904-1-git-send-email-antonio.murdaca@gmail.com>
References: <1433143750-13904-1-git-send-email-antonio.murdaca@gmail.com>
Message-ID: <20150601120703.GA6580@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jun 01, 2015 at 09:29:10AM +0200, Antonio Murdaca wrote:
> cleanup checkpatch.pl warnings about not needed else
> clauses after a break or return
> 
> Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>

Any reason you sent 4 copies of this and didn't cc the driverdevel
mailing list on any of them?

Please fix that up and resend 1 copy, we get enough email as it is :)

thanks,

greg k-h
