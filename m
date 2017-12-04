From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 4 Dec 2017 23:01:34 +0300
Subject: [lustre-devel] [PATCH v3] staging: lustre: Replace 'uint32_t'
 with 'u32' and 'uint64_t' with 'u64'
In-Reply-To: <20171204194502.GA12057@home>
References: <20171129164621.GA10881@home>
 <20171130060846.jghmmojo45ropbol@mwanda>
 <20171204194502.GA12057@home>
Message-ID: <20171204200134.m56ucf4jfnvln2lz@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 04, 2017 at 10:45:02PM +0300, Roman Storozhenko wrote:
> On Thu, Nov 30, 2017 at 09:08:46AM +0300, Dan Carpenter wrote:
> > On Wed, Nov 29, 2017 at 07:46:21PM +0300, Roman Storozhenko wrote:
> > > There are two reasons for that:
> > 
> > In my email client the subject line and body are not next to each other.
> > It looks like this:
> > 
> > https://marc.info/?l=linux-arm-kernel&m=151187366315885&w=2
> > 
> > So it took me a while to realize what you were talking about.  Please
> > assume I'm either reading the subject or the body but not both.
> > 
> > regards,
> > dan carpenter
> > 
> Hello Dan,
> 
> It's really strange. Moreover the screenshot that you have provided doesn't
> relate to my patch. Anyway I checked the source file of the message
> (I use 'mutt -H <source_file>) and found that body goes below the
> subject with one empty separate line (according to patch format
> recomendations).

Mutt is very configurable.  Mine looks like the marc.info link.  The
patch was chosen at random to show how the subject and body are not
next to each other.

regards,
dan carpenter
