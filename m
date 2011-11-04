From: Brian J. Murrell <brian@whamcloud.com>
Date: Fri, 04 Nov 2011 17:47:42 -0400
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
 and
In-Reply-To: <8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
Message-ID: <1320443263.7466.26.camel@brian-laptop>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2011-11-04 at 10:40 -0600, Andreas Dilger wrote:
> On 2011-11-03, at 4:28 PM, Prakash Surya <surya1@llnl.gov> wrote:
> > I like the idea of cleaning up the commit messages in Lustre, although I
> > feel enforcing these rules is better suited at the server level.
> 
> There are already limited checks at the server level, and they may be tightened in the near future.

And the most the server (which is Gerrit that we are talking about her)
can do is to negatively review the patch as it does currently.  There is
no mechanism to outright refuse to allow a push based on the content of
the patch, so client-side is still the best place to apply these checks
in an effort to prevent the patch from even being submitted if not
correct.

b.
