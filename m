From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 8 Jun 2015 12:38:26 -0700
Subject: [lustre-devel] [PATCH v3 3/8] staging:lustre: delete no longer
	used LNet headers
In-Reply-To: <1433364207-14307-4-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
	<1433364207-14307-4-git-send-email-jsimmons@infradead.org>
Message-ID: <20150608193826.GA12667@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 03, 2015 at 04:43:22PM -0400, James Simmons wrote:
> Remove the linux specific headers for LNet since they are
> mostly empty. Also api-support.h and lnet-sysctl.h is not
> needed by anyone. Lastly we delete ptllnd.h and ptllnd_wire.h
> which were used by Cray hardware that no longer exist.
> With the deletion of the headers some conditionals and
> wrappers that no longer exist are handled directly in the
> source code. Alongside that some user land router code is
> also removed.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>

Doesn't apply to my tree, please refresh and resend this and the rest of
this series.

thanks,

greg k-h
