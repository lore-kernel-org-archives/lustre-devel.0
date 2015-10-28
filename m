From: Greg KH <greg@kroah.com>
Date: Thu, 29 Oct 2015 07:45:13 +0900
Subject: [lustre-devel] [PATCH 5/5] staging:lustre: Update license and
 copyright for kernel comm
In-Reply-To: <ef7c51eacffd4e9880cd39c0ede13348@EXCHCS32.ornl.gov>
References: <562E051D.6030807@gmail.com>
	<ef7c51eacffd4e9880cd39c0ede13348@EXCHCS32.ornl.gov>
Message-ID: <20151028224513.GA31326@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 28, 2015 at 07:00:29PM +0000, Simmons, James A. wrote:
> >>
> >> - * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
> >> - *
> >> - * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
> >> - * CA 95054 USA or visit www.sun.com if you need additional information or
> >> - * have any questions.
> >
> >That text is in every files. You should kill all references.
> 
> That would be a mighty big patch.

I can take "mighty big patches" like this quite easily, please send it
to me, don't mess with this "development branch of an external tree"
nonsense, which I'm _REALLY_ getting tired of.

Please drop that tree and only use the in-kernel version.  If that
doesn't work for you, then we need to drop the in-kernel version as it's
pretty obvious no one is actually using this in-kernel code.

thanks,

greg k-h
