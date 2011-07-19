From: Mark Hills <Mark.Hills@framestore.com>
Date: Tue, 19 Jul 2011 17:08:08 +0100 (BST)
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <CAA6TbrM8LSL41forun6bFgaV5gvRju0rJaJJd3piFPQTwTkSJA@mail.gmail.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<CAA6TbrM8LSL41forun6bFgaV5gvRju0rJaJJd3piFPQTwTkSJA@mail.gmail.com>
Message-ID: <alpine.LFD.2.01.1107191701270.9249@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 19 Jul 2011, Richard Henwood wrote:

> On Tue, Apr 26, 2011 at 11:06 AM, Mark Hills <Mark.Hills@framestore.com> wrote:
> > We've often found it inconvenient that reads from Lustre mounts do not
> > correctly increment IO counts (/proc/<pid>/io).
> >
> > Below is a patch which aims to fix this functionality.
> >
> > The symptom is that writes are accounted for, but not reads. It seems that
> > the accounting it normally done in the kernels page writeback and
> > readahead functionality. Therefore as Lustre implements its own readahead,
> > it must also maintain its own accounting on reads (but not writes).
> >
> 
> Hi Mark;
> 
> Are you aware of the (soon to land) patch:
> Lustre client procfs stats: read_bytes does not record the number of
> bytes transfered from the fs:
> http://jira.whamcloud.com/browse/LU-333

I was aware of these stats (and this patch), but I concluded that they did 
not track memory mapped access.

So I think our patches address two separate parts of the process. But I'm 
happy to be corrected -- it was some time ago that I did this.

-- 
Mark
